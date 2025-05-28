{
  config,
  lib,
  inputs,
  self,
  ...
}:

let
  ciSystems = lib.intersectLists lib.platforms.linux config.systems ++ [ "x86_64-darwin" ];

  configurationsFor = lib.genAttrs ciSystems (
    lib.flip self.lib.collectNestedDerivationsFor {
      inherit (self) nixosConfigurations homeConfigurations darwinConfigurations;
    }
  );

  mapUniqueAttrNames = prefix: lib.mapAttrs (lib.const (self.lib.makeUniqueAttrNames prefix));
in

{
  flake = {
    githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
      checks = self.lib.mergeAttrsList' [
        configurationsFor

        (mapUniqueAttrNames "checks" { inherit (self.checks) x86_64-linux; })
        (mapUniqueAttrNames "devShells" { inherit (self.devShells) x86_64-linux x86_64-darwin; })
      ];
    };
  };

  perSystem =
    {
      config,
      pkgs,
      ...
    }:

    {
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
          dependencies = [ pkgs.nixfmt-rfc-style ];
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
