{ config, lib, ... }:

{
  config = lib.mkMerge [
    {
      services.resolved = {
        enable = lib.mkDefault true;
        dnsovertls = "true";
      };
    }

    (lib.mkIf config.services.resolved.enable {
      networking = {
        nameservers = [
          "1.1.1.1#one.one.one.one"
          "1.0.0.1#one.one.one.one"
        ];

        networkmanager.dns = "systemd-resolved";
      };
    })
  ];
}
