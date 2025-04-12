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
            path = "/run/hedgedoc/hedgedoc.sock";

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
            proxyPass = "http://unix:" + cfg.settings.path;
            proxyWebsockets = true;
          };
        };
      };

      users.groups.hedgedoc.members = [ config.services.nginx.user ];
    })
  ];
}
