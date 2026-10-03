{
  config,
  lib,
  secretsDir,
  ...
}:

let
  interface = "wg0";
  subnet = "10.100.100";
  cfg = config.networking.wireguard;
  cfg' = cfg.interfaces.${interface};

  peerToAddress =
    peer:
    let
      removeCIDRPrefix = cidr: lib.substring 0 (lib.stringLength cidr - 3) cidr;
      ip = lib.head peer.allowedIPs |> removeCIDRPrefix;
    in
    "/${peer.name}/${ip}";
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
        allowedUDPPorts = lib.mkIf config.services.dnsmasq.enable [ 53 ];
        allowedTCPPorts = lib.mkIf config.services.openssh.enable config.services.openssh.ports;
      };
    };

    services = {
      dnsmasq = {
        enable = true;

        settings = {
          address = map peerToAddress (
            cfg'.peers
            ++ [
              {
                name = config.networking.hostName;
                allowedIPs = cfg'.ips;
              }
            ]
          );

          inherit interface;
          no-hosts = true;
          no-resolv = true;
          server = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };
      };

      openssh = {
        listenAddresses = [ { addr = "${subnet}.1"; } ];
        ports = [ 420 ];
      };
    };

    # NOTE: Required since WG subnet isn't available at boot
    systemd.services.sshd = lib.mkIf config.services.openssh.enable {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
  })
]
