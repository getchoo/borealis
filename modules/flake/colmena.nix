{
  config,
  lib,
  inputs,
  self,
  ...
}:

let
  namespace = "colmena";

  nodes = lib.filterAttrs (
    name: _:
    !(lib.elem name [
      "meta"
      "defaults"
    ])
  ) config.${namespace};
  hasNodes = lib.length (lib.attrNames nodes) > 0;

  metaSubmodule = {
    options = {
      allowApplyAll = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to allow deployments without a node filter set.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        description = "A short description for the configuration.";
        example = lib.literalExpression "A Colmena Hive";
      };

      machinesFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Use the machines listed in this file when building this hive configuration.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "hive";
        description = "The name of the configuration.";
      };

      nixpkgs = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = inputs.nixpkgs.legacyPackages.x86_64-linux;
        defaultText = lib.literalExpression "inputs.nixpkgs.legacyPackages.x86_64-linux";
        description = "The pinned Nixpkgs package set.";
        example = lib.literalExpression ''
          import inputs.nixpkgs { system = "x86_64-linux"; }
        '';
      };

      nodeNixpkgs = lib.mkOption {
        type = lib.types.attrsOf (lib.types.lazyAttrsOf lib.types.raw);
        default = { };
        description = "Node-specific Nixpkgs pins.";
      };

      nodeSpecialArgs = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
        description = "Node-specific special args.";
      };

      specialArgs = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
        description = "A set of special arguments to be passed to NixOS modules.";
      };
    };
  };

  colmenaSubmodule = {
    freeformType = lib.types.lazyAttrsOf lib.types.deferredModule;

    options = {
      meta = lib.mkOption {
        type = lib.types.submodule metaSubmodule;
        default = { };
        description = ''
          Options for the `meta` attribute set.

          See <link xlink:href="https://colmena.cli.rs/unstable/reference/meta.html"/>
        '';
      };

      defaults = lib.mkOption {
        type = lib.types.deferredModule;
        default = { };
        description = "Module imported by all nodes.";
      };
    };
  };
in

{
  options.${namespace} = lib.mkOption {
    type = lib.types.submodule colmenaSubmodule;
    default = { };
    description = ''
      Options for `colmena`.

      See <link xlink:href="https://colmena.cli.rs/unstable/"/>
    '';
  };

  config = lib.mkIf hasNodes {
    flake = {
      inherit (config) colmena;
      colmenaHive = inputs.colmena.lib.makeHive self.colmena;
    };
  };
}
