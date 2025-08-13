{ lib, self, ... }:

let
  # NOTE: This only flattens one level of attrs. It should probably be recursive
  flattenAttrs = lib.concatMapAttrs (
    prefix: lib.mapAttrs' (name: lib.nameValuePair "${prefix}-${name}")
  );

  mapCfgsToDrvs = lib.mapAttrs (lib.const (v: v.config.system.build.toplevel or v.activationPackage));
  filterCompatibleCfgs =
    system: lib.filterAttrs (lib.const (v: v.pkgs.stdenv.hostPlatform.system == system));
in

{
  perSystem =
    {
      config,
      pkgs,
      system,
      self',
      ...
    }:

    let
      configurations = lib.mapAttrs (lib.const (v: mapCfgsToDrvs (filterCompatibleCfgs system v))) {
        inherit (self) nixosConfigurations homeConfigurations darwinConfigurations;
      };
    in

    {
      checks = flattenAttrs (
        configurations
        // {
          inherit (self') devShells;
        }
      );

      legacyPackages = {
        tflint = config.quickChecks.tflint.package;
      };

      quickChecks = {
        actionlint = {
          dependencies = [ pkgs.actionlint ];
          script = "find ${self}/.github/workflows -type f -name '*.nix' -exec actionlint {} +";
        };

        deadnix = {
          dependencies = [ pkgs.deadnix ];
          script = "deadnix --fail ${self}";
        };

        hclfmt = {
          dependencies = [ pkgs.hclfmt ];
          script = "hclfmt -require-no-change ${self}/terraform/*.tf";
        };

        just = {
          dependencies = [ pkgs.just ];
          script = ''
            cd ${self}
            just --check --fmt --unstable
            just --summary
          '';
        };

        nixfmt = {
          dependencies = [ pkgs.nixfmt ];
          script = "find ${self} -type f -name '*.nix' -exec nixfmt --check {} +";
        };

        statix = {
          dependencies = [ pkgs.statix ];
          script = "statix check ${self}";
        };

        tflint = {
          dependencies = [ pkgs.tflint ];
          script = ''
            tflint --chdir=${self}/terraform --format=sarif |& tee $out || true
          '';
        };
      };
    };
}
