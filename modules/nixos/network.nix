{
  config,
  lib,
  ...
}: let
  cfg = config.nixos.networking;
  inherit (lib) mkEnableOption mkIf;
in {
  options.nixos.networking.enable = mkEnableOption "enable networking";

  config = mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
    services.resolved = {
      enable = lib.mkDefault true;
      dnssec = "allow-downgrade";
      extraConfig = ''
        [Resolve]
        DNS=1.1.1.1 1.0.0.1
        DNSOverTLS=yes
      '';
    };
  };
}
