{
  config,
  lib,
  ...
}:

let
  domain = lib.removePrefix "https://" config.services.miniflux.config.BASE_URL;
in

{
  config = lib.mkIf config.services.miniflux.enable {
    borealis.reverseProxies.${domain} = {
      socket = lib.head config.systemd.sockets.miniflux.listenStreams;
    };

    # TODO: Re-enable when we aren't denied access to the postgres socket
    security.apparmor.enable = false;

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
