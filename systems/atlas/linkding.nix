{ config, ... }:

let
  domain = "linkding." + config.networking.domain;
  publicPort = "9090";

  dataDir = "/var/lib/linkding";
in

{
  borealis.reverseProxies.${domain} = {
    address = "localhost:" + publicPort;
  };

  virtualisation.oci-containers.containers = {
    linkding = {
      image = "ghcr.io/sissbruecker/linkding:latest-alpine";
      autoStart = true;

      ports = [ "${publicPort}:9090" ];
      volumes = [ "${dataDir}:/etc/linkding/data" ];
      # Contains a lot of OIDC stuff
      environmentFiles = [ "/etc/linkding.conf" ];
      environment = {
        LD_CSRF_TRUSTED_ORIGINS = "https://" + domain;
      };
    };
  };
}
