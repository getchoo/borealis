{ config, lib, ... }:

let
  kanidmCfg = config.services.kanidm;
  certDirectory = config.security.acme.certs.${kanidmCfg.serverSettings.domain}.directory;
in

{
  config = lib.mkMerge [
    {
      services.kanidm = {
        clientSettings = {
          uri = lib.mkDefault kanidmCfg.serverSettings.origin;
        };

        serverSettings = {
          tls_chain = certDirectory + "/fullchain.pem";
          tls_key = certDirectory + "/key.pem";
          domain = lib.mkDefault ("auth." + config.networking.domain);
          origin = lib.mkDefault ("https://" + config.services.kanidm.serverSettings.domain);

          online_backup = {
            versions = lib.mkDefault 7; # Keep a week's worth of backups
          };
        };
      };
    }

    (lib.mkIf kanidmCfg.enableServer {
      services.nginx.virtualHosts.${kanidmCfg.serverSettings.domain} = {
        locations."/" = {
          proxyPass = "https://" + kanidmCfg.serverSettings.bindaddress;
        };
      };
    })
  ];
}
