{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in

{
  config = lib.mkMerge [
    (lib.mkIf isLinux {
      services.gpg-agent = {
        enable = lib.mkDefault config.programs.gpg.enable;
        pinentry.package = osConfig.programs.gnupg.agent.pinentryPackage or pkgs.pinentry-curses;
      };
    })
  ];
}
