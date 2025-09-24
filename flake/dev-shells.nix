{
  perSystem =
    {
      pkgs,
      inputs',
      self',
      ...
    }:

    {
      devShells = {
        default = pkgs.mkShellNoCC {
          packages = [
            # For CI
            pkgs.actionlint

            # Nix tools
            pkgs.nil
            pkgs.statix
            self'.formatter

            pkgs.just
            pkgs.opentofu

            inputs'.agenix.packages.agenix
          ];
        };
      };
    };
}
