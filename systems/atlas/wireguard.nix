{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:

let
  interface = "wg0";
  subnet = "10.100.100";
  cfg = config.networking.wireguard;
  cfg' = cfg.interfaces.${interface};

  removeCIDRPrefix = cidr: lib.substring 0 (lib.stringLength cidr - 3) cidr;
  peerToRecord = peer: {
    key = {
      type = 1;
      name = "${peer.name}.internal";
    };
    address = lib.head peer.allowedIPs |> removeCIDRPrefix;
  };
in

lib.mkMerge [
  {
    networking.wireguard = {
      enable = true;

      interfaces.${interface} = {
        listenPort = 51820;
        ips = [ "${subnet}.1/24" ];
        privateKeyFile = config.age.secrets.wireguardKey.path;

        peers = [
          {
            name = "glados-windows";
            publicKey = "j98gcxDnFMhyePogKXlSUqcGdEOMdip4+lnQM/VAmjM=";
            allowedIPs = [ "${subnet}.2/32" ];
          }
        ];
      };
    };
  }

  (lib.mkIf cfg.enable {
    age.secrets = {
      wireguardKey = {
        file = "${secretsDir}/wireguard.age";
        mode = "700";
      };
    };

    networking.firewall = {
      allowedUDPPorts = [ cfg'.listenPort ];

      interfaces.${interface} = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = lib.mkIf config.services.openssh.enable config.services.openssh.ports;
      };
    };

    services = {
      openssh = {
        listenAddresses = [ { addr = "${subnet}.1"; } ];
        ports = [ 420 ];
      };

      resolved.settings = {
        Resolve = {
          DNSStubListenerExtra = "${subnet}.1";
        };
      };
    };

    systemd = {
      # NOTE: Required since WG subnet isn't available at boot
      services.sshd = lib.mkIf config.services.openssh.enable {
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
      };

      tmpfiles.settings.internal-static-records = {
        "/etc/systemd/resolve/static.d/internal.rr".C = {
          argument =
            cfg'.peers
            ++ [
              {
                name = config.networking.hostName;
                allowedIPs = cfg'.ips;
              }
            ]
            |> map peerToRecord
            |> (pkgs.formats.json { }).generate "internal.rr"
            |> toString;
        };
      };
    };
  })
]
