{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:

{
  config = lib.mkMerge [
    {
      environment = {
        plasma6.excludePackages = with pkgs.kdePackages; [
          discover
          khelpcenter
          konsole
          plasma-browser-integration
        ];
      };

      services.displayManager.sddm = {
        wayland.enable = true;
      };
    }

    (lib.mkIf config.services.desktopManager.plasma6.enable {
      environment = {
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };

        systemPackages = [
          inputs'.krunner-nix.packages.default # Thank you Leah
          pkgs.ghostty
          pkgs.haruna # MPV frontend
        ];
      };

      services.displayManager.sddm = {
        enable = lib.mkDefault true;
      };
    })
  ];
}
