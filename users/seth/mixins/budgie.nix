{ lib, osConfig, ... }:

let
  enable = osConfig.services.xserver.desktopManager.budgie.enable or false;
in

{
  config = lib.mkIf enable {
    dconf = {
      enable = true;
      settings = {
        "com.solus-project.budgie-panel:Budgie" = {
          pinned-launchers = [
            "firefox.desktop"
            "nemo.desktop"
            "discord-canary.desktop"
          ];
        };
      };
    };
  };
}
