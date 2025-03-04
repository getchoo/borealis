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
    inputs.getchpkgs.homeModules.arkenfox
    inputs.getchpkgs.homeModules.firefox-addons
  ];

  config = lib.mkMerge [
    {
      programs.firefox = {
        addons = [
          # uBlock Origin
          { id = "uBlock0@raymondhill.net"; }
          # Bitwarden
          { id = "{446900e4-71c2-419f-a6a7-df9c091e268b}"; }
          # Floccus
          { id = "floccus@handmadeideas.org"; }
        ];

        profiles.arkenfox = {
          arkenfox = {
            enable = true;
            version = "133.0";
          };

          isDefault = true;

          settings = {
            # Disable Firefox Accounts & Pocket
            "extensions.pocket.enabled" = false;
            "identity.fxaccounts.enabled" = false;

            # Hardware acceleration
            "media.ffmpeg.vaapi.enabled" = true;

            # Widevine drm
            "media.gmp-widevinecdm.enabled" = true;

            # ===
            ## Arkenfox overrides
            # ===

            # 1201: Fix Hulu
            "security.ssl.require_safe_negotiation" = false;

            # 2651: Download to my downloads
            "browser.download.useDownloadDir" = true;

            # 5003: I use Bitwarden
            "signon.rememberSignons" = true;
            # 5021: Enable search from URL bar by default
            "keyword.enabled" = true;
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
