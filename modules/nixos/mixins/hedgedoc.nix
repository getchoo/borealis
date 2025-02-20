{
  config,
  lib,
  secretsDir,
  ...
}:

let
  hedgedocCfg = config.services.hedgedoc;
  oauth2Domain = "https://" + config.services.kanidm.serverSettings.domain;
in

{
  config = lib.mkMerge [
    {
      services = {
        hedgedoc = {
          settings = {
            domain = lib.mkDefault ("hedgedoc." + config.networking.domain);
            port = 4000;

            allowOrigin = [
              hedgedocCfg.settings.domain
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

    (lib.mkIf hedgedocCfg.enable {
      services = {
        nginx.virtualHosts.${hedgedocCfg.settings.domain} = {
          locations."/" = {
            proxyPass = "http://${hedgedocCfg.settings.host}:${toString hedgedocCfg.settings.port}";
            proxyWebsockets = true;
          };
        };
      };
    })

    (lib.mkIf (hedgedocCfg.enable && config.services.kanidm.enableServer) {
      age.secrets.hedgedocClientSecret.file = secretsDir + "/hedgedocClientSecret.age";

      services.hedgedoc = {
        environmentFile = config.age.secrets.hedgedocClientSecret.path;

        settings = {
          email = false;

          oauth2 = {
            clientID = "hedgedoc";
            clientSecret = "$CMD_OAUTH2_CLIENT_SECRET";
            providerName = "Kanidm";

            baseURL = oauth2Domain;
            authorizationURL = oauth2Domain + "/ui/oauth2";
            tokenURL = oauth2Domain + "/oauth2/token";
            userProfileURL = oauth2Domain + "/oauth2/openid/hedgedoc/userinfo";

            scope = "openid email profile";
            userProfileDisplayNameAttr = "name";
            userProfileEmailAttr = "email";
            userProfileUsernameAttr = "preferred_username";
          };
        };
      };
    })
  ];
}
