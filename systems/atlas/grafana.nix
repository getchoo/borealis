{ config, ... }:

{
  services = {
    grafana = {
      enable = true;
    };

    nginx.virtualHosts = {
      "grafana.getchoo.com" = {
        locations."/" = {
          proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
