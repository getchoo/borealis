{
  config,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.miniflux.enable {
    services = {
      nginx.virtualHosts.${lib.removePrefix "https://" config.services.miniflux.config.BASE_URL} = {
        locations."/" = {
          proxyPass = "http://${config.services.miniflux.config.LISTEN_ADDR}";
        };
      };
    };

    /*
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
    */
  };
}
