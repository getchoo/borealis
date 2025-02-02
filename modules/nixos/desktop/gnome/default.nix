{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.gnome;
in
{
  options.desktop.gnome.enable = lib.mkEnableOption "GNOME desktop";

  config = lib.mkIf cfg.enable {
    environment = {
      gnome.excludePackages = with pkgs; [
        gnome-tour
        totem # Replaced with celluloid
        seahorse # Replaced with key-rack
      ];

      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        # For qadwaitadecorations
        QT_WAYLAND_DECORATION = "adwaita";
      };

      systemPackages = [
        # Make GTK3 apps look good
        pkgs.adw-gtk3
        # Media player
        pkgs.celluloid
        # Checksum verifier
        pkgs.collision
        # Audio player
        pkgs.decibels
        # Screen recorder
        pkgs.kooha
        # Secret manager
        pkgs.key-rack
        # Fix Qt app client decorations
        pkgs.qadwaitadecorations
        pkgs.qadwaitadecorations-qt6
        # Task manager
        pkgs.resources
        # Emoji picker
        pkgs.smile
        pkgs.video-trimmer
      ];
    };

    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
