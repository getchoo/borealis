{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.borealis.profiles.desktop;
in

{
  options.borealis.profiles.desktop = {
    enable = lib.mkEnableOption "the desktop profile";
  };

  config = lib.mkIf cfg.enable {
    borealis = {
      users = {
        seth.enable = true;
      };
    };

    nix.settings = {
      extra-trusted-substituters = [
        "https://nix-community.cachix.org"
      ];

      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    nixpkgs.overlays = [
      inputs.nix.overlays.default

      (final: prev: {
        nix = prev.nix.appendPatches [
          # https://github.com/NixOS/nix/pull/14041
          (final.fetchpatch2 {
            name = "avoid-re-copying-substituted-inputs.patch";
            url = "https://github.com/NixOS/nix/commit/5e90b64add409edcf774cb1e1807ab931b7ac296.patch";
            hash = "sha256-JrLi2ahEhriMt/qB+9Zx8NQilUBBnvvn8rYsUICYrxE=";
          })
        ];
      })
    ];

    services = {
      tailscale.enable = lib.mkDefault true;
    };
  };
}
