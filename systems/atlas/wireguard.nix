{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:

let
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

  interface = "wg0";
  proto = {
    "v4" = {
      iptables = lib.getExe pkgs.iptables;
      subnet = "10.100.100";
      addr = "${proto.v4.subnet}.1/24";
    };

    "v6" = {
      iptables = lib.getExe' pkgs.iptables "iptables6";
      subnet = "fd00:1234:5678";
      addr = "${proto.v6.subnet}::1/64";
    };
  };
  ipAddrs = lib.mapAttrsToList (lib.const (lib.getAttr "addr")) proto;
  ipAddrsNoCIDR = map removeCIDRPrefix ipAddrs;
  genIptableRules = fn: lib.mapAttrsToList (lib.const fn) proto |> lib.concatLines;
in

lib.mkMerge [
  {
    networking.wireguard = {
      enable = true;

      interfaces.${interface} = {
        listenPort = 51820;
        ips = ipAddrs;
        privateKeyFile = config.age.secrets.wireguardKey.path;

        peers = [
          {
            name = "glados-windows";
            publicKey = "j98gcxDnFMhyePogKXlSUqcGdEOMdip4+lnQM/VAmjM=";
            allowedIPs = [
              "${proto.v4.subnet}.2/32"
              "${proto.v6.subnet}::2/128"
            ];
          }
          {
            name = "iphone";
            publicKey = "H1TgusyvaXklTkP3f6MjvY//LCGxpSrcUnHp8DbxyHo=";
            allowedIPs = [
              "${proto.v4.subnet}.3/32"
              "${proto.v6.subnet}::3/128"
            ];
          }
        ];

        postSetup = genIptableRules (
          { iptables, addr, ... }: ''
            ${iptables} -A FORWARD -i ${interface} -j ACCEPT
            ${iptables} -t nat -A POSTROUTING -s ${addr} -o eth0 -j MASQUERADE
          ''
        );

        postShutdown = genIptableRules (
          { iptables, addr, ... }: ''
            ${iptables} -D FORWARD -i ${interface} -j ACCEPT
            ${iptables} -t nat -D POSTROUTING -s ${addr} -o eth0 -j MASQUERADE
          ''
        );
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

    networking = {
      firewall = {
        allowedUDPPorts = [ cfg'.listenPort ];

        interfaces.${interface} = {
          allowedUDPPorts = [ 53 ];
          allowedTCPPorts = lib.mkIf config.services.openssh.enable config.services.openssh.ports;
        };
      };

      nat = {
        enable = true;
        enableIPv6 = true;
        externalInterface = "enp0s6";
        internalInterfaces = [ interface ];
      };
    };

    services = {
      openssh = {
        listenAddresses = map (addr: { inherit addr; }) ipAddrsNoCIDR;
      };

      resolved.settings = {
        Resolve = {
          DNSStubListenerExtra = ipAddrsNoCIDR;
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
