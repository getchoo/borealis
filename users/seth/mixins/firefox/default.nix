{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
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

    (lib.mkIf (config.programs.firefox.enable && isLinux) {
      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
      };
    })
  ];
}
