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
          proxyPass = "http://unix:${lib.head config.systemd.sockets.miniflux.listenStreams}";
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
  };
}
