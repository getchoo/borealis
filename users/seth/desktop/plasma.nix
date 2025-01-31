{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  enable = osConfig.services.desktopManager.plasma6.enable or false;
in
{
  config = lib.mkIf enable {
    home.packages = [
      # Matrix client
      # TODO: Use after it drops libolm
      # pkgs.kdePackages.neochat
      # Mastodon client
      pkgs.kdePackages.tokodon
      # Torrent client
      pkgs.qbittorrent
    ];
  };
}
