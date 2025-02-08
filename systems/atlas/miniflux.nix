{ config, secretsDir, ... }:

{
  age.secrets.miniflux.file = secretsDir + "/miniflux.age";

  services = {
    miniflux = {
      enable = true;
      adminCredentialsFile = config.age.secrets.miniflux.path;
      config = {
        BASE_URL = "https://miniflux.${config.networking.domain}";
        LISTEN_ADDR = "localhost:7000";
      };
    };

    nginx = {
      virtualHosts = {
        "miniflux.getchoo.com" = {
          locations."/" = {
            proxyPass = "http://${config.services.miniflux.config.LISTEN_ADDR}";
          };
        };
      };
    };
  };
}
