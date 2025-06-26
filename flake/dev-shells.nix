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

      nix = inputs'.dix.packages.default;
      nixos-rebuild = pkgs.nixos-rebuild-ng.override { inherit nix; };
    in

    {
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
