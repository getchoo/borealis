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
            "chromium-browser.desktop"
            "org.gnome.Nautilus.desktop"
            "discord-canary.desktop"
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
          name = "ptyxis";
          command = "ptyxis";
          binding = "<Control><Alt>t";
        };
      };
    };

    # Required for adwaita-ize
    gtk.enable = true;

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

    # The regular Spotify client is weird sometimes
    services.spotifyd.enable = true;

    seth.tweaks.adwaita-ize.enable = true;
  };
}
