{ lib, ... }:

{
  services.prometheus.exporters.node = {
    openFirewall = lib.mkDefault true;

    enabledCollectors = [
      "systemd"
    ];
  };
}
