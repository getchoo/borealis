{ self, ... }:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      self',
      system,
      ...
    }:

    let
      collectNestedDerivations = self.lib.collectNestedDerivationsFor system;
    in

    lib.mkMerge [
      {
        checks = collectNestedDerivations {
          inherit (self)
            nixosConfigurations
            homeConfigurations
            darwinConfigurations
            ;
        };

        legacyPackages = {
          tflint = config.quickChecks.tflint.package;
        };
      }

      # I don't really care to run these on other systems
      (lib.mkIf (system == "x86_64-linux") {
        checks = collectNestedDerivations { inherit (self') devShells; };

        quickChecks = {
          actionlint = {
            dependencies = [ pkgs.actionlint ];
            script = "actionlint ${self}/.github/workflows/**";
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
            script = "nixfmt --check ${self}/**/*.nix";
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
      })
    ];
}
