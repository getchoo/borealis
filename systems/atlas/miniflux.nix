{
  config,
  lib,
  secretsDir,
  ...
}:

{
  age.secrets.miniflux.file = secretsDir + "/miniflux.age";

  services = {
    miniflux = {
      enable = true;
      adminCredentialsFile = config.age.secrets.miniflux.path;
      config = {
        BASE_URL = "https://miniflux.${config.networking.domain}";
      };
    };

    nginx.virtualHosts = {
      "miniflux.getchoo.com" = {
        locations."/" = {
          proxyPass = "http://unix:${lib.head config.systemd.sockets.miniflux.listenStreams}";
        };
      };
    };
  };

  systemd = {
    services.miniflux = {
      requires = [ "miniflux.socket" ];
    };

    sockets.miniflux = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "/run/miniflux.sock" ];
    };
  };
}
