{ config, lib, ... }:

let
  forgejoCfg = config.services.forgejo;
in

{
  config = lib.mkMerge [
    {
      services.forgejo = {
        database = {
          type = "postgres";
        };

        settings = {
          server = {
            PROTOCOL = "http+unix";
            DOMAIN = lib.mkDefault ("git." + config.networking.domain);
            ROOT_URL = "https://" + forgejoCfg.settings.server.DOMAIN + "/";

            DISABLE_SSH = lib.mkDefault true;
          };

          oauth2_client = {
            ENABLE_AUTO_REGISTRATION = lib.mkDefault true;
          };

          service = {
            DISABLE_REGISTRATION = lib.mkDefault true;
          };

          packages = {
            ENABLED = lib.mkDefault false;
          };

          actions = {
            ENABLED = lib.mkDefault false;
          };
        };
      };
    }

    (lib.mkIf forgejoCfg.enable {
      services.nginx.virtualHosts.${forgejoCfg.settings.server.DOMAIN} = {
        locations."/" = {
          proxyPass = "http://unix:${forgejoCfg.settings.server.HTTP_ADDR}";
        };
      };
    })
  ];
}
