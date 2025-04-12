{ config, lib, ... }:

let
  cfg = config.services.navidrome;
in

{
  borealis.reverseProxies."music.${config.networking.domain}" = {
    socket = lib.removePrefix "unix:" cfg.settings.Address;
  };

  services = {
    navidrome = {
      enable = true;

      settings = {
        Address = "unix:/run/navidrome/navidrome.sock";
        MusicFolder = "/srv/music";
      };
    };
  };

  systemd.services.navidrome = {
    serviceConfig = {
      EnvironmentFile = "/etc/navidrome.conf";
    };
  };

  # Required for NGINX to access the Unix socket
  users.groups.${config.services.navidrome.group} = {
    members = [ config.services.nginx.user ];
  };
}
