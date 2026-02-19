{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  cfg = config.seth.profiles.desktop;
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  hasGui = osConfig.services.xserver.enable or false;
  hasSteam = osConfig.programs.steam.enable or false;
in

{
  options.seth.profiles.desktop = {
    enable = lib.mkEnableOption "desktop profile" // {
      default = osConfig.borealis.profiles.desktop.enable or false;
      defaultText = lib.literalExpression "osConfig.borealis.profiles.desktop.enable or false";
    };
  };

  config = lib.mkIf (cfg.enable && isLinux && hasGui) {
    home.packages = [
      pkgs._1password-gui

      (pkgs.discord.overrideAttrs (old: {
        # Discord currently uses Chromium 130
        # https://github.com/elFarto/nvidia-vaapi-driver/issues/5#issuecomment-2421082537
        preInstall =
          (lib.replaceString " --enable-features=WaylandWindowDecorations" "" old.preInstall or "")
          + ''
            gappsWrapperArgs+=(--add-flags "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks")
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
      mangohud.enable = lib.mkIf hasSteam true;
    };
  };
}
