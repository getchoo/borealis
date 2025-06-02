{
  perSystem =
    {
      lib,
      pkgs,
      inputs',
      self',
      ...
    }:

    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;

      nix = self'.legacyPackages.dix;
      nixos-rebuild = pkgs.nixos-rebuild-ng.override { inherit nix; };
    in

    {
      legacyPackages = {
        dix = inputs'.dix.packages.default.overrideScope (
          _: prev: {
            nix-flake = prev.nix-flake.overrideAttrs (old: {
              patches = old.patches or [ ] ++ [ ./allow-registry-lookups-for-overridden-inputs.patch ];
              patchFlags = old.patchFlags or [ ] ++ [ "-p3" ];
            });
          }
        );
      };

      devShells = {
        default = pkgs.mkShellNoCC {
          packages =
            [
              # We want to make sure we have the same
              # Nix behavior across machines
              nix

              # For CI
              pkgs.actionlint

              # Nix tools
              pkgs.nil
              pkgs.statix
              self'.formatter

              pkgs.just
              pkgs.opentofu

              # See above comment about Nix
              nixos-rebuild
              inputs'.agenix.packages.agenix
            ]
            ++ lib.optionals isDarwin [
              # Ditto
              inputs'.nix-darwin.packages.darwin-rebuild
            ];
        };
      };
    };
}
