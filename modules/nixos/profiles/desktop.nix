{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.borealis.profiles.desktop;
in

{
  config = lib.mkIf cfg.enable {
    _module.args = {
      secretsDir = inputs.self + "/secrets/personal";
    };

    environment.systemPackages = lib.mkIf config.services.xserver.enable [
      pkgs.chromium
      pkgs.wl-clipboard
    ];

    programs = {
      nix-ld.enable = lib.mkDefault true;
    };

    system.rebuild.enableNg = true;
  };
}
