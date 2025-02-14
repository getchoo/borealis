{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkMerge [
    {
      services.xserver = {
        excludePackages = [ pkgs.xterm ];
      };
    }

    (lib.mkIf config.services.xserver.enable {
      environment.systemPackages = [
        pkgs.wl-clipboard
      ];

      programs = {
        chromium.enable = lib.mkDefault true;
      };

      services = {
        pipewire.enable = true;
      };
    })
  ];
}
