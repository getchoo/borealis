{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  config = lib.mkIf config.determinate.enable {
    nix.package = lib.mkForce pkgs.nix;

    nixpkgs.overlays = [
      (_: prev: { nix = inputs.self.legacyPackages.${prev.stdenv.hostPlatform.system}.dix; })
    ];
  };
}
