{
  config,
  lib,
  pkgs,
  ...
}:

let
  isDesktop = config.borealis.profiles.desktop.enable;
in

{
  fonts = {
    enableDefaultPackages = lib.mkDefault isDesktop;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans

      nerd-fonts.hack
    ];

    fontconfig = {
      enable = lib.mkDefault isDesktop;
      defaultFonts = lib.mkDefault {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Hack Nerd Font" ];
      };
    };
  };
}
