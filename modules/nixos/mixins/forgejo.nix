{
  config,
  lib,
  inputs,
  ...
}:

let
  forgejoCfg = config.services.forgejo;

  robotsTxtPath = forgejoCfg.stateDir + "/custom/public/robots.txt";
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
            PROTOCOL = "http";
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
          proxyPass = "http://${forgejoCfg.settings.server.HTTP_ADDR}:${toString forgejoCfg.settings.server.HTTP_PORT}";
        };
      };

      systemd.tmpfiles.settings."forgejo-settings" = {
        ${robotsTxtPath}."L+" = {
          argument = inputs.codeberg-infra + "/etc/gitea/public/robots.txt";
        };

        ${dirOf robotsTxtPath}.d = {
          inherit (forgejoCfg) user group;
        };
      };
    })
  ];
}
