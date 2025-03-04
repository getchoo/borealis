{
  config,
  lib,
  inputs,
  self,
  ...
}:

let
  cfg = config.deploy;

  deployLib = inputs.deploy-rs.lib;

  hasNodes = cfg.nodes != [ ];
  hasSettings = cfg.settings != { };

  genericOptions = {
    freeformType = lib.types.attrsOf (
      lib.types.oneOf [
        lib.types.str
        lib.types.bool
        lib.types.int
        lib.types.null
      ]
    );

    options = {
      activationTimeout = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        defaultText = lib.literalExpression "240";
        description = "Timeout for profile activation in seconds.";
      };

      autoRollback = lib.mkEnableOption "rollback if activation fails" // {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        defaultText = lib.literalExpression "true";
      };

      confirmationTimeout = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        defaultText = lib.literalExpression "30";
        description = "Timeout for profile activation confirmation in seconds.";
      };

      fastConnection = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        defaultText = lib.literalExpression "false";
        description = ''
          Whether to enable fast connection to the node.

          If this is true, copy the whole closure instead of letting the node substitute.
        '';
      };

      interactiveSudo = lib.mkEnableOption "interactive sudo (password based sudo)" // {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        defaultText = lib.literalExpression "false";
      };

      magicRollback = lib.mkEnableOption "magic rollback" // {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        defaultText = lib.literalExpression "true";
      };

      remoteBuild = lib.mkEnableOption "building on the target system" // {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        defaultText = lib.literalExpression "false";
      };

      sshUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          The user that deploy-rs will use when connecting.

          This will default to your own username if not specified anywhere.
        '';
      };

      sshOpts = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "An optional list of arguments that will be passed to SSH.";
      };

      sudo = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        defaultText = "sudo -u";
        description = ''
          Which sudo command to use.

          Must accept at least two arguments:
          The user name to execute commands as and the rest is the command to execute.
        '';
      };

      user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        defaultText = lib.literalExpression "config.sshUser";
        description = ''
          The user that the profile will be deployed to.

          Will use sudo if not the same as `sshUser`
        '';
      };

      tempPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        defaultText = "/tmp";
        description = ''
          The path which deploy-rs will use for temporary files.

          If `magicRollback` is in use, this *must* be writable by `user`.
        '';
      };
    };
  };

  nodeSubmodule =
    { name, ... }:
    {
      imports = [ genericOptions ];

      options = {
        hostname = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "The hostname of your server.";
        };

        profilesOrder = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = ''
            An optional list containing the order you want profiles to be deployed.

            This will take effect whenever you run `deploy` without specifying a profile, causing it to deploy every profile automatically.
            Any profiles not in this list will still be deployed (in an arbitrary order) after those which are listed.
          '';
        };

        profiles = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              imports = [ genericOptions ];

              # TODO: Add `profilePath`
              options = {
                path = lib.mkOption {
                  type = lib.types.lazyAttrsOf lib.types.raw;
                  description = "NixOS closure path to activate on target";
                  default = self.nixosConfigurations.${name};
                  apply =
                    configuration:
                    let
                      inherit (configuration.pkgs.stdenv.hostPlatform) system;
                    in
                    deployLib.${system}.activate.nixos configuration;
                  defaultText = lib.literalExpression "self.nixosConfigurations.${name}";
                };
              };
            }
          );
          default = {
            system = { };
          };
          defaultText = lib.literalExpression "{ system = { self.nixosConfigurations.\${name}; }; }";
        };
      };

      config = {
        sshUser = lib.mkDefault "root";
      };
    };

  settingsSubmodule = {
    imports = [ genericOptions ];

    options = {
      nodes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule nodeSubmodule);
        default = { };
      };
    };
  };
in

{
  options.deploy = {
    nodes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of nixosConfiguration names to create deploy-rs nodes for";
    };

    useChecks = lib.mkEnableOption "deploy-rs checks";

    settings = lib.mkOption {
      type = lib.types.submodule settingsSubmodule;
      default = { };
      description = ''
        Options for deploy-rs.

        See https://github.com/serokell/deploy-rs?tab=readme-ov-file#api
        for supported values.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf hasNodes {
      deploy.settings = {
        nodes = lib.genAttrs cfg.nodes (lib.const { });
      };
    })

    (lib.mkIf hasSettings {
      flake.deploy = lib.filterAttrsRecursive (lib.const (value: value != null)) cfg.settings;
    })

    (lib.mkIf (hasSettings && cfg.useChecks) {
      perSystem =
        { system, ... }:

        lib.mkIf (lib.elem system (lib.attrNames inputs.deploy-rs.lib)) {
          checks = deployLib.${system}.deployChecks self.deploy;
        };
    })
  ];
}
