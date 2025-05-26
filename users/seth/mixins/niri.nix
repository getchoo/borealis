{
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  enable = osConfig.programs.niri.enable or false;
in

{
  config = lib.mkIf enable {
    # Set dark theme for Flatpak apps
    # https://github.com/YaLTeR/niri/wiki/Important-Software#portals
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };

    home.packages = [
      # Torrent client
      pkgs.fragments

      # Mastodon client
      pkgs.tuba

      # the funni (I need it for native Wayland support)
      pkgs.vesktop

      # TODO: Figure out how to export $DISPLAY from this
      # so I don't need the above
      pkgs.xwayland-satellite
    ];

    # Enable some things from the NixOS module here to
    # apply Catppuccin themes
    programs = {
      alacritty.enable = true;
      fuzzel.enable = true;
      ncspot.enable = true; # Official Spotify has ugly CSD
      swaylock.enable = true;
      yazi.enable = true;
      zellij.enable = true;
    };

    services = {
      mako.enable = true;
    };

    seth = {
      adw-gtk3.enable = true;
    };
  };
}
