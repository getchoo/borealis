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
      };

      systemPackages = [
        pkgs.adw-gtk3 # Make gtk3 apps look good
        pkgs.celluloid
        pkgs.kooha
        pkgs.key-rack
      ];
    };

    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
