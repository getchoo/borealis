{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.xserver.enable {
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
