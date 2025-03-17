{
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  enable = osConfig.services.xserver.desktopManager.gnome.enable or false;
in

{
  config = lib.mkIf enable {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;

          enabled-extensions = [ "caffeine@patapon.info" ];

          favorite-apps = [
            "firefox.desktop"
            "org.gnome.Nautilus.desktop"
            "discord.desktop"
          ];
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          document-font-name = "Noto Sans 11";
          font-antialiasing = "rgba";
          font-name = "Noto Sans 11";
          monospace-font-name = "Hack Nerd Font 10";
        };

        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
        };

        "org/gnome/desktop/wm/preferences" = {
          titlebar-font = "Noto Sans Bold 11";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "ghostty";
          command = "ghostty";
          binding = "<Control><Alt>t";
        };
      };
    };

    home.packages = [
      # Torrent client
      pkgs.fragments

      # Keep my screen awake
      pkgs.gnomeExtensions.caffeine

      # Terminal emulator
      pkgs.ptyxis

      # Mastodon client
      pkgs.tuba
    ];

    seth.adw-gtk3.enable = true;
  };
}
