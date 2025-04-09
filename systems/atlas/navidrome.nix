{ config, lib, ... }:

let
  cfg = config.services.navidrome;
in

{
  services = {
    navidrome = {
      enable = true;

      settings = {
        MusicFolder = "/srv/music";
      };
    };

    nginx = {
      virtualHosts."navidrome.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://${
            lib.concatStringsSep ":" [
              cfg.settings.Address
              (toString cfg.settings.Port)
            ]
          }";
        };
      };
    };
  };
}
