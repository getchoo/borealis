{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  cfg = config.seth.profiles.nixos;

  isNixOSDesktop = osConfig.services.xserver.enable or false;
  hasSteam = osConfig.programs.steam.enable or false;
in

{
  options.seth.profiles.nixos = {
    enable = lib.mkEnableOption "NixOS profile" // {
      default = isNixOSDesktop;
      defaultText = lib.literalExpression "osConfig.services.xserver.enable or false";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.discord.overrideAttrs (old: {
        # Discord currently uses Chromium 130
        # https://github.com/elFarto/nvidia-vaapi-driver/issues/5#issuecomment-2421082537
        preInstall = old.preInstall or "" + ''
          gappsWrapperArgs+=(--add-flags "--enable-features=VaapiOnNvidiaGPUs,VaapiVideoDecodeLinuxGL,VaapiVideoDecodeLinuxZeroCopyGL")
        '';
      }))

      # Matrix client
      pkgs.element-desktop

      (pkgs.prismlauncher.override {
        jdks = with pkgs; [
          temurin-bin-8 # TODO: Maybe replace when `jdk8` isn't broken
          jdk17
          jdk21
        ];
      })

      (pkgs.spotify.overrideAttrs {
        # Spotify doesn't work well on Wayland natively. Don't force it
        preFixup = ''
          gappsWrapperArgs+=(--unset NIXOS_OZONE_WL)
        '';
      })
    ];

    programs = {
      chromium.enable = true;
      firefox.enable = true;
      ghostty.enable = true;
      mangohud.enable = hasSteam;
    };
  };
}
