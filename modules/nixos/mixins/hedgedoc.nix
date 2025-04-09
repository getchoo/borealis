{
  config,
  lib,
  ...
}:

let
  cfg = config.services.hedgedoc;
in

{
  config = lib.mkMerge [
    {
      services = {
        hedgedoc = {
          settings = {
            port = 4000;

            allowOrigin = [
              cfg.settings.domain
              "localhost"
            ];

            # Managed by reverse proxy
            protocolUseSSL = true;
            urlAddPort = false;

            allowAnonymous = false;
          };
        };
      };
    }

    (lib.mkIf cfg.enable {
      services = {
        nginx.virtualHosts.${cfg.settings.domain} = {
          locations."/" = {
            proxyPass = "http://${cfg.settings.host}:${toString cfg.settings.port}";
            proxyWebsockets = true;
          };
        };
      };
    })
  ];
}
