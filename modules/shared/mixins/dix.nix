{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  config = lib.mkMerge [
    {
      determinate.enable = lib.mkDefault false;
    }

    (lib.mkIf config.determinate.enable {
      nix.package = lib.mkForce pkgs.nix;

      nixpkgs.overlays = [
        inputs.dix.overlays.default

        (final: prev: {
          nixVersions = prev.nixVersions.extend (
            _: _: {
              nixComponents_2_30 = final.nix.libs;
              nixComponents_2_31 = final.nix.libs;
            }
          );
        })
      ];
    })
  ];
}
