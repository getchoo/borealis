{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.borealis.profiles.personal;
in

{
  options.borealis.profiles.personal = {
    enable = lib.mkEnableOption "the Personal profile";
  };

  config = lib.mkIf cfg.enable {
    _module.args = {
      secretsDir = inputs.self + "/secrets/personal";
    };

    borealis = {
      users = {
        seth.enable = lib.mkDefault true;
      };
    };

    environment.systemPackages = [ (pkgs.nixos-rebuild-ng.override { nix = config.nix.package; }) ];

    lix.enable = true;

    services = {
      tailscale.enable = lib.mkDefault true;
    };
  };
}
