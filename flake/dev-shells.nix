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

      nix = pkgs.nixVersions.git;
      nixos-rebuild = pkgs.nixos-rebuild-ng.override { inherit nix; };
    in

    {
      devShells = {
        default = pkgs.mkShellNoCC {
          packages = [
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

            inputs'.agenix.packages.agenix
          ]
          ++ lib.optionals isLinux [
            # See above comment about Nix
            nixos-rebuild
          ]
          ++ lib.optionals isDarwin [
            # Ditto
            inputs'.nix-darwin.packages.darwin-rebuild
          ];
        };
      };
    };
}
