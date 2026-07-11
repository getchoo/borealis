{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkMerge [
    {
      environment = {
        plasma6.excludePackages = with pkgs.kdePackages; [
          discover
          khelpcenter
          plasma-browser-integration
          kwin-x11
        ];
      };

      services.desktopManager.plasma6 = {
        enableQt5Integration = lib.mkDefault false;
      };
    }

    (lib.mkIf config.services.desktopManager.plasma6.enable {
      environment = {
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };

        systemPackages = [
          pkgs.haruna # MPV frontend
        ];
      };

      services.displayManager.plasma-login-manager = {
        enable = lib.mkDefault true;
      };
    })
  ];
}
