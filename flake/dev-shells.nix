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
      inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

      nix = inputs'.lix-module.packages.default;

      overrideNix = p: p.override { inherit nix; };
      nixos-rebuild = overrideNix pkgs.nixos-rebuild;
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
            ]
            ++ lib.optionals isDarwin [
              inputs'.nix-darwin.packages.darwin-rebuild
            ]
            ++ lib.optionals isLinux [
              # See above comment about Nix
              nixos-rebuild

              inputs'.agenix.packages.agenix
            ];
        };
      };
    };
}
