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
      borealis.reverseProxies.${cfg.settings.domain} = {
        socket = cfg.settings.path;
      };

      # Required to access the above socket
      users.groups.hedgedoc.members = [ config.services.nginx.user ];
    })
  ];
}
