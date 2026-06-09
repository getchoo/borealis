{ config, lib, ... }:

let
  cfg = config.services.kanidm;

  inherit (cfg.server.settings) domain;
  certDirectory = config.security.acme.certs.${domain}.directory;
in

{
  config = lib.mkMerge [
    {
      services.kanidm = {
        client.settings = {
          uri = lib.mkDefault cfg.server.settings.origin;
        };

        server.settings = {
          tls_chain = certDirectory + "/fullchain.pem";
          tls_key = certDirectory + "/key.pem";
          origin = lib.mkDefault ("https://" + domain);

          online_backup = {
            versions = lib.mkDefault 7; # Keep a week's worth of backups
          };
        };
      };
    }

    (lib.mkIf cfg.server.enable {
      borealis.reverseProxies.${domain} = {
        locations."/".proxyPass = "https://" + cfg.server.settings.bindaddress;
      };

      security.acme.certs.${domain} = {
        group = config.users.groups.kanidm.name;
      };

      # Share the SSL cert with NGINX
      users.groups.kanidm = {
        members = [
          config.services.nginx.user
        ];
      };
    })
  ];
}
