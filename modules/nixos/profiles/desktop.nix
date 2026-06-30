{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.borealis.profiles.desktop;
in

{
  config = lib.mkIf cfg.enable {
    _module.args = {
      secretsDir = inputs.self + "/secrets/personal";
    };

    environment.systemPackages = lib.mkIf config.services.xserver.enable [
      pkgs.chromium
      pkgs.wl-clipboard
    ];

    nixpkgs.overlays = lib.mkIf config.services.xserver.enable [
      (final: prev: {
        chromium = prev.chromium.override {
          enableWideVine = final.config.allowUnfree;
        };
      })
    ];

    programs = {
      _1password-gui.enable = lib.mkDefault (
        config.services.xserver.enable && config.programs._1password.enable
      );
      nix-ld.enable = lib.mkDefault true;
    };
  };
}
