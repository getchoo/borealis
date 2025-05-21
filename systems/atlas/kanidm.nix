{ config, secretsDir, ... }:

let
  cfg = config.services.kanidm;
  oauth2Domain = "https://" + cfg.serverSettings.domain;
in

{
  age.secrets = {
    hedgedocClientSecret.file = secretsDir + "/hedgedocClientSecret.age";
  };

  services = {
    kanidm = {
      enableClient = true;
      enableServer = true;

      serverSettings = {
        domain = "auth." + config.networking.domain;
      };
    };

    hedgedoc = {
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
  };
}
