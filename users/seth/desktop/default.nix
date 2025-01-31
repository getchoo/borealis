{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.seth.desktop;
in
{
  options.seth.desktop = {
    enable = lib.mkEnableOption "desktop (Linux) settings" // {
      default = osConfig.desktop.enable or false;
      defaultText = lib.literalExpression "osConfig.desktop.enable or false";
    };
  };

  imports = [
    ./budgie.nix
    ./gnome.nix
    ./niri.nix
    ./plasma.nix
  ];

  config = lib.mkIf cfg.enable {
    # This is meant for Linux
    assertions = [ (lib.hm.assertions.assertPlatform "seth.desktop" pkgs lib.platforms.linux) ];

    home.packages = [
      pkgs.discord
      pkgs.prismlauncher
    ];

    programs.ghostty.enable = true;
  };
}
