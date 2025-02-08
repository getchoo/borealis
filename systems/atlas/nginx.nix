{ config, ... }:

{
  services.nginx = {
    virtualHosts = {
      "miniflux.getchoo.com" = {
        locations."/" = {
          proxyPass = "http://${config.services.miniflux.config.LISTEN_ADDR}";
        };
      };
    };
  };
}
