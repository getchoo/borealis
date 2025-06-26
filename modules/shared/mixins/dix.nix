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
      (_: _: { nix = inputs'.dix.packages.default; })
    ];
  };
}
