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

  # Create the socket manually to ensure NGINX has permission for the socket's parent directory
  # ...since for some reason Miniflux will not give it the same `0777` permission as the socket itself
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
