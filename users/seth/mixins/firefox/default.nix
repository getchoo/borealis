{
  lib,
  osConfig,
  inputs,
  ...
}:

let
  usingNvidia = lib.elem "nvidia" osConfig.services.xserver.videoDrivers or [ ];
in

{
  imports = [
    inputs.getchpkgs.nixosModules.firefox-addons
    # Requires `github:dwarfmaster/arkenfox-nixos`
    # ./arkenfox.nix
  ];

  config = lib.mkMerge [
    {
      programs.firefox = {
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
    }

    # Required workarounds for nvidia-vaapi-driver
    # https://github.com/elFarto/nvidia-vaapi-driver?tab=readme-ov-file#firefox
    (lib.mkIf usingNvidia {
      home.sessionVariables = {
        MOZ_DISABLE_RDD_SANDBOX = "1";
      };

      programs.firefox = {
        profiles.arkenfox.settings = {
          "media.av1.enabled" = false;
          "media.rdd-ffmpeg.enabled" = true;
          "widget.dmabuf.force-enabled" = true;
        };
      };
    })
  ];
}
