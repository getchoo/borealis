{ inputs, self, ... }:

{
  imports = [
    ./ci.nix
    ./dev-shells.nix
    ./lix.nix
    ./treefmt.nix
  ];

  perSystem =
    { system, ... }:

    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.lix-module.overlays.default
          self.overlays.lix-patches
        ];
      };
    };
}
