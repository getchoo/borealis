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
    in

    {
      devShells = {
        default = pkgs.mkShellNoCC {
          packages =
            [
              # We want to make sure we have the same
              # Nix behavior across machines
              pkgs.nix

              # For CI
              pkgs.actionlint

              # Nix tools
              pkgs.nil
              pkgs.statix
              self'.formatter

              pkgs.just
              pkgs.opentofu

              # See above comment about Nix
              pkgs.nixos-rebuild
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
