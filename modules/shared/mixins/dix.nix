{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:

{
  config = lib.mkIf config.determinate.enable {
    nix.package = lib.mkForce pkgs.nix;

    nixpkgs.overlays = [
      (final: _: {
        nix = inputs'.dix.packages.default;
        # Dix should be API compatible with upstream Nix
        nixForLinking = final.nix;
      })
    ];
  };
}
