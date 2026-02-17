{
  config,
  lib,
  pkgs,
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

    nix = {
      settings = {
        extra-trusted-substituters = [
          "https://nix-community.cachix.org"
        ];

        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    nixpkgs.overlays = [
      (_: prev: {
        nixVersions = prev.nixVersions.extend (
          _: prev': {
            stable = prev'.latest;
          }
        );
      })
    ];

    services = {
      tailscale.enable = lib.mkDefault true;
    };
  };
}
