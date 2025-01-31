{
  perSystem =
    {
      lib,
      pkgs,
      inputs',
      self',
      ...
    }:

    {
      devShells.default = pkgs.mkShellNoCC {
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
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            # See above comment about Nix
            inputs'.nix-darwin.packages.darwin-rebuild
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            # Ditto
            pkgs.nixos-rebuild

            inputs'.agenix.packages.agenix
          ];
      };
    };
}
