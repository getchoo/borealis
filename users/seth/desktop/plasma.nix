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

      pkgs.spotify
    ];

    xdg = {
      dataFile."konsole/catppuccin-mocha.colorscheme".source =
        pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "konsole";
          rev = "7d86b8a1e56e58f6b5649cdaac543a573ac194ca";
          hash = "sha256-EwSJMTxnaj2UlNJm1t6znnatfzgm1awIQQUF3VPfCTM=";
        }
        + "/Catppuccin-Mocha.colorscheme";
    };
  };
}
