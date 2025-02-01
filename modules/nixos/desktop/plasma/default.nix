{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
let
  cfg = config.desktop.plasma;
in
{
  options.desktop.plasma.enable = lib.mkEnableOption "Plasma desktop";

  config = lib.mkIf cfg.enable {
    environment = {
      plasma6.excludePackages = with pkgs.kdePackages; [
        discover
        khelpcenter
        konsole
        plasma-browser-integration
      ];

      systemPackages = [
        inputs'.krunner-nix.packages.default # thank you leah
        pkgs.ghostty
        pkgs.haruna # mpv frontend
      ];
    };

    services = {
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };

      desktopManager.plasma6.enable = true;
    };
  };
}
