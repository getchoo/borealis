{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.fonts;
in
{
  options.desktop.fonts = {
    enable = lib.mkEnableOption "desktop fonts" // {
      default = config.desktop.enable;
      defaultText = lib.literalExpression "config.desktop.enable";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;

      packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-sans

        nerd-fonts.hack
      ];

      fontconfig = {
        enable = true;
        defaultFonts = lib.mkDefault {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          emoji = [ "Noto Color Emoji" ];
          monospace = [ "Hack Nerd Font" ];
        };
      };
    };
  };
}
