{ config, lib, ... }:

let
  cfg = config.borealis.reverseProxies;

  proxySubmodule =
    { config, name, ... }:

    let
      usingUnixSocket = config.socket != null;
    in

    {
      freeformType = lib.types.attrsOf lib.types.anything;

      options = {
        serverName = lib.mkOption {
          type = lib.types.str;
          default = name;
          defaultText = "Name of the attribute.";
          example = "example.org";
        };

        address = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "HTTP address to proxy.";
        };

        socket = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Unix socket to proxy";
        };

        virtualHostOptions = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          internal = true;
        };
      };

      config = lib.mkMerge [
        {
          virtualHostOptions = lib.mkMerge [
            (lib.removeAttrs config [
              "address"
              "socket"
              "virtualHostOptions"
            ])

            {
              locations."/" = {
                proxyPass = "http://" + lib.optionalString usingUnixSocket "unix:" + config.address;
                proxyWebsockets = true;
              };
            }
          ];
        }

        (lib.mkIf usingUnixSocket {
          address = lib.mkDefault (toString config.socket);
        })
      ];
    };
in

{
  options.borealis.reverseProxies = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule proxySubmodule);
    default = { };
    description = "An attribute set describing services to proxy.";
  };

  config = lib.mkIf (cfg != { }) {
    services.nginx.virtualHosts = lib.mapAttrs (lib.const (lib.getAttr "virtualHostOptions")) cfg;
  };
}
