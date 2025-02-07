{ config, lib, ... }:

let
  inherit (lib)
    attrValues
    filter
    flip
    match
    mkOption
    recursiveUpdate
    removeAttrs
    removePrefix
    types
    ;

  inherit (lib.filesystem) listFilesRecursive;

  cfg = config;

  toRelativePath = filePath: removePrefix (toString cfg.rootDirectory + "/") (toString filePath);

  handleSecretRegex =
    secret:

    let
      secretRegexMatches = str: match secret.regex str != null;
      matched = filter (filePath: secretRegexMatches (toRelativePath filePath)) secretFiles;
    in

    map (
      path:
      recursiveUpdate secret {
        path = toRelativePath path;
      }
    ) matched;

  secretFiles = listFilesRecursive cfg.rootDirectory;

  failedAssertions = map (x: x.message) (filter (x: !x.assertion) cfg.assertions);
  assertionsMessage = "\nFailed assertions:\n${lib.concatLines (map (x: "- " + x) failedAssertions)}";

  agenixSecretSubmodule = {
    freeformType = lib.types.attrsOf types.anything;

    options = {
      publicKeys = mkOption {
        type = types.listOf types.str;
        defaultText = "config.recipients.default";
        description = "List of public keys a given secret is encrypted for.";
      };
    };
  };

  recipientsSubmodule = {
    freeformType = types.attrsOf types.str;

    options = {
      default = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Recipetents added to secrets by default.";
      };
    };
  };

  recipientsOptionSubmodule = {
    options = {
      recipients = mkOption {
        type = types.submodule recipientsSubmodule;
        default = { };
        description = "Recipetents that files will be encrypted for.";
      };
    };
  };

  secretSettingsSubmodule =
    { config, ... }:

    {
      imports = [ recipientsOptionSubmodule ];

      options = {
        recipients = mkOption {
          # We only use this in the toplevel `config.recipients`
          apply = flip removeAttrs [ "default" ];
        };

        useDefault = lib.mkEnableOption "the default recipients" // {
          default = true;
        };

        settings = mkOption {
          type = types.submodule agenixSecretSubmodule;
          default = { };
          description = ''
            Settings for a given secret.

            Loosely documented in the agenix [tutorial](https://github.com/ryantm/agenix#tutorial).
          '';
        };
      };

      # Dogfood `settings` to apply global and per-secret recipients
      # Use `mkForce` to override
      config = lib.mkMerge [
        {
          settings.publicKeys = attrValues config.recipients;
        }

        (lib.mkIf config.useDefault {
          settings.publicKeys = cfg.recipients.default;
        })
      ];
    };

  secretPathSubmodule = {
    imports = [ secretSettingsSubmodule ];

    options = {
      path = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Relative path (to `config.rootDirectory`) of a secret";
      };

      regex = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "A regex for a given file path relative to `config.rootDirectory`.";
      };
    };
  };

  # TODO: Re-implement when can `types.either (types.submodule ...) (types.submodule ...)` works
  # It would be good to avoid the `nullOr` above and assertions below
  /*
    secretRegexSubmodule = {
      imports = [ secretSettingsSubmodule ];

      options = {
        regex = mkOption {
          type = types.str;
          description = "A regex for a given file path relative to `config.rootDirectory`.";
        };
      };
    };
  */

  buildSubmodule = {
    options = {
      rules = mkOption {
        type = types.attrsOf (types.submodule agenixSecretSubmodule);
        readOnly = true;
        description = "Final rules passed to the agenix CLi.";
      };
    };
  };
in

{
  imports = [
    recipientsOptionSubmodule

    <nixpkgs/nixos/modules/misc/assertions.nix>
  ];

  options = {
    rootDirectory = mkOption {
      type = types.path;
      description = "Root directory containing agenix secrets.";
    };

    secrets = mkOption {
      # TODO: Use `types.listOf (types.either ...)`
      type = types.listOf (types.submodule secretPathSubmodule);
      default = { };
      description = "Submodule describing agenix secrets.";
    };

    # Outputs
    build = mkOption {
      type = types.submodule buildSubmodule;
      default = { };
      apply = build: if failedAssertions != [ ] then throw assertionsMessage else build;
      internal = true;
    };
  };

  config = {
    assertions = map (secret: {
      assertion = secret.path != null || secret.regex != null;
      message = "One of `path` or `regex` must be set";
    }) cfg.secrets;

    build = {
      # TODO: Harvest all secrets
      rules = lib.listToAttrs (
        lib.concatMap (
          secret:

          let
            normalized = if secret.regex != null then handleSecretRegex secret else [ secret ];
          in

          map (secret': lib.nameValuePair secret'.path secret'.settings) normalized
        ) cfg.secrets
      );
    };
  };
}
