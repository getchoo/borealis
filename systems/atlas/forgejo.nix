{ config, ... }:

let
  forgejoCfg = config.services.forgejo;
in

{
  mixins.forgejo.enable = true;

  services.nginx.virtualHosts = {
    "git.getchoo.com" = {
      enableACME = false;
      forceSSL = false;

      locations."/" = {
        proxyPass = "http://unix:${forgejoCfg.settings.server.HTTP_ADDR}";
      };
    };
  };
}
