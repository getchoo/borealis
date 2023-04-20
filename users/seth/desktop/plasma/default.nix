{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop.plasma;
  inherit (lib) mkEnableOption mkIf;
in {
  options.desktop.plasma.enable = mkEnableOption "enable plasma";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      catppuccin-cursors
      catppuccin-kde
      catppuccin-kvantum
      libsForQt5.qtstyleplugin-kvantum
      papirus-icon-theme
    ];

    xdg.dataFile."konsole/catppuccin-mocha.colorscheme".source =
      pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "konsole";
        rev = "7d86b8a1e56e58f6b5649cdaac543a573ac194ca";
        sha256 = "EwSJMTxnaj2UlNJm1t6znnatfzgm1awIQQUF3VPfCTM=";
      }
      + "/Catppuccin-Mocha.colorscheme";
  };
}
