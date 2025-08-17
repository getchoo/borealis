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
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.chromium
      pkgs.wl-clipboard
    ];
  };
}
