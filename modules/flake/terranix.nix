{
  config,
  lib,
  flake-parts-lib,
  inputs,
  ...
}:

let
  inherit (flake-parts-lib) mkSubmoduleOptions;

  namespace = "terranix";
  cfg = config.${namespace};
in

{
  options.terranix = mkSubmoduleOptions {
    package = lib.mkOption {
      type = lib.types.functionTo lib.types.package;
      default = pkgs: pkgs.opentofu;
      defaultText = lib.literalExpression "pkgs: pkgs.opentofu";
      description = "The Terraform-compatible implementation to use.";
      example = lib.literalExpression "pkgs: pkgs.terraform";
    };

    modules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
    };
  };

  config = {
    perSystem =
      {
        lib,
        pkgs,
        system,
        ...
      }:

      let
        package = cfg.package pkgs;

        terranixConfiguration = inputs.terranix.lib.terranixConfiguration {
          inherit system;
          inherit (cfg) modules;
        };
      in

      {
        apps.tf = {
          program = pkgs.writeShellScriptBin "tf" ''
            ln -sf ${terranixConfiguration} config.tf.json
            exec ${lib.getExe package} "$@"
          '';
        };
      };
  };
}
