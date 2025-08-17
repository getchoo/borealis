{
  config,
  lib,
  pkgs,
  ...
}:

let
  isGuiDesktop = config.borealis.profiles.desktop.enable && config.services.xserver.enable;
in

{
  fonts = {
    enableDefaultPackages = lib.mkDefault isGuiDesktop;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans

      nerd-fonts.hack
    ];

    fontconfig = {
      enable = lib.mkDefault isGuiDesktop;
      defaultFonts = lib.mkDefault {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Hack Nerd Font" ];
      };
    };
  };
}
