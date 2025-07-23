{ config, lib, ... }:

{
  options = {
    services.nginx.virtualHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          config = {
            enableACME = lib.mkDefault true;
            forceSSL = lib.mkDefault true;
          };
        }
      );
    };
  };

  config = lib.mkMerge [
    {
      services.nginx = {
        enableReload = true;

        recommendedBrotliSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
      };
    }

    (lib.mkIf config.services.nginx.enable {
      security.acme.defaults.reloadServices = [ "nginx.service" ];
    })
  ];
}
