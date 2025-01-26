{
  config,
  lib,
  withSystem,
  self,
  ...
}:

{
  perSystem =
    { pkgs, ... }:
    {
      quickChecks = {
        actionlint = {
          dependencies = [ pkgs.actionlint ];
          script = "actionlint ${self}/.github/workflows/**";
        };

        deadnix = {
          dependencies = [ pkgs.deadnix ];
          script = "deadnix --fail ${self}";
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
      };
    };

  flake.hydraJobs =

    let
      # Architecture of "main" CI machine
      ciSystem = "x86_64-linux";

      derivFromCfg = deriv: deriv.config.system.build.toplevel or deriv.activationPackage;
      mapCfgsToDerivs = lib.mapAttrs (lib.const derivFromCfg);
    in

    lib.genAttrs config.systems (
      lib.flip withSystem (
        {
          system,
          self',
          ...
        }:

        let
          mapCfgsForSystem =
            cfgs: lib.filterAttrs (lib.const (deriv: deriv.system == system)) (mapCfgsToDerivs cfgs);
        in

        {
          darwinConfigurations = mapCfgsForSystem self.darwinConfigurations;
          homeConfigurations = mapCfgsForSystem self.homeConfigurations;
          nixosConfigurations = mapCfgsForSystem self.nixosConfigurations;
        }
        # I don't care to run these for each system, as they should be the same
        # and don't need to be cached
        // lib.optionalAttrs (system == ciSystem) {
          inherit (self') checks devShells;
        }
      )
    );
}
