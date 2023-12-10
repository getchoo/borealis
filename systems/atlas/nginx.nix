{
  config,
  lib,
  ...
}: let
  inherit (config.networking) domain;

  mkProxy = endpoint: port: {
    "${endpoint}" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
  };

  mkVHosts = let
    commonSettings = {
      enableACME = true;
      # workaround for https://github.com/NixOS/nixpkgs/issues/210807
      acmeRoot = null;

      addSSL = true;
    };
  in
    lib.mapAttrs (_: lib.recursiveUpdate commonSettings);
in {
  server.services.cloudflared.enable = true;

  services.nginx = {
    enable = true;

    clientMaxBodySize = "2048m"; # 2GB
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = mkVHosts {
      "cache.${domain}" = {
        locations = mkProxy "/" "5000";
      };

      "miniflux.${domain}" = {
        locations = mkProxy "/" "7000";
      };

      "msix.${domain}" = {
        root = "/var/www/msix";
      };
    };
  };
}
