{ config, lib, pkgs, ... }:

let
  kanidmCfg = config.services.kanidm;

  inherit (kanidmCfg.serverSettings) domain;
  certDirectory = config.security.acme.certs.${domain}.directory;
  certGroup = config.users.groups.nginx-kanidm;
in

{
  config = lib.mkMerge [
    {
      services.kanidm = {
        package = pkgs.kanidm_1_5;

        clientSettings = {
          uri = lib.mkDefault kanidmCfg.serverSettings.origin;
        };

        serverSettings = {
          tls_chain = certDirectory + "/fullchain.pem";
          tls_key = certDirectory + "/key.pem";
          domain = lib.mkDefault ("auth." + config.networking.domain);
          origin = lib.mkDefault ("https://" + domain);

          online_backup = {
            versions = lib.mkDefault 7; # Keep a week's worth of backups
          };
        };
      };
    }

    (lib.mkIf kanidmCfg.enableServer {
      security.acme.certs.${domain} = {
        group = config.users.groups.nginx-kanidm.name;
      };

      services.nginx.virtualHosts.${domain} = {
        locations."/" = {
          proxyPass = "https://" + kanidmCfg.serverSettings.bindaddress;
        };
      };

      # Create a group for Kanidm and NGINX so they can share the domain's SSL certificate
      users = {
        groups.nginx-kanidm = { };

        users = {
          kanidm.extraGroups = [ certGroup.name ];
          ${config.services.nginx.user}.extraGroups = [ certGroup.name ];
        };
      };
    })
  ];
}
