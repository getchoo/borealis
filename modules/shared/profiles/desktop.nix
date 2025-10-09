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

      # TODO: Remove this!
      # Un-vendor toml11 to fix build failures with the Nix flake's override
      # https://github.com/NixOS/nix/pull/14199
      (final: prev: {
        nix = prev.nix.overrideScope (
          _: _: {
            inherit (final) toml11;
          }
        );
      })
    ];

    services = {
      tailscale.enable = lib.mkDefault true;
    };
  };
}
