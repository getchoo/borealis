{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.borealis.profiles.desktop;
in

{
  options.borealis.profiles.desktop = {
    enable = lib.mkEnableOption "the desktop profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.chromium
      pkgs.wl-clipboard
    ];
  };
}
