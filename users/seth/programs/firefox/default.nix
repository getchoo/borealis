{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.seth.programs.firefox;
in
{
  options.seth.programs.firefox = {
    enable = lib.mkEnableOption "Firefox configuration";
  };

  imports = [
    inputs.getchpkgs.nixosModules.firefox-addons
    # Requires `github:dwarfmaster/arkenfox-nixos`
    # ./arkenfox.nix
  ];

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };

    programs.firefox = {
      enable = true;

      addons = [
        # uBlock Origin
        "uBlock0@raymondhill.net"
        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}"
        # Floccus
        "floccus@handmadeideas.org"
      ];

      profiles.arkenfox = {
        isDefault = true;

        settings = {
          # disable firefox accounts & pocket
          "extensions.pocket.enabled" = false;
          "identity.fxaccounts.enabled" = false;

          # hw accel
          "media.ffmpeg.vaapi.enabled" = true;

          # widevine drm
          "media.gmp-widevinecdm.enabled" = true;
        };
      };
    };
  };
}
