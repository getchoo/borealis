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

  # TODO: Support other `networking.firewall` backends
  iptables4 = "iptables";
  iptables6 = "iptables6";
  forEachIptables = lib.flip map [
    iptables4
    iptables6
  ];

  interface = "wg0";
  ipv4Subnet = "10.100.100";
  ipv6Subnet = "fd00:1234:5678";
  ipv4Addr = "${ipv4Subnet}.1/24";
  ipv6Addr = "${ipv6Subnet}::1/64";
  ipAddrs = [
    ipv4Addr
    ipv6Addr
  ];
  ipAddrsNoCIDR = map removeCIDRPrefix ipAddrs;

  iptablesAddrFor = lib.genAttrs [ iptables4 iptables6 ] (
    name: if name == iptables6 then ipv6Addr else ipv4Addr
  );
  genIptableRules = fn: forEachIptables (iptables: fn iptables iptablesAddrFor.${iptables});
in

lib.mkMerge [
  {
    networking.wireguard = {
      enable = true;

      interfaces.${interface} = {
        listenPort = 51820;
        ips = [
          ipv4Addr
          ipv6Addr
        ];
        privateKeyFile = config.age.secrets.wireguardKey.path;

        peers = [
          {
            name = "glados-windows";
            publicKey = "j98gcxDnFMhyePogKXlSUqcGdEOMdip4+lnQM/VAmjM=";
            allowedIPs = [
              "${ipv4Subnet}.2/32"
              "${ipv6Subnet}::2/128"
            ];
          }
          {
            name = "iphone";
            publicKey = "H1TgusyvaXklTkP3f6MjvY//LCGxpSrcUnHp8DbxyHo=";
            allowedIPs = [
              "${ipv4Subnet}.3/32"
              "${ipv6Subnet}::3/128"
            ];
          }
        ];

        postSetup = genIptableRules (
          iptables: addr: ''
            ${iptables} -A FORWARD -i wg0 -j ACCEPT
            ${iptables} -t nat -A POSTROUTING -s ${addr} -o eth0 -j MASQUERADE
          ''
        );

        postShutdown = genIptableRules (
          iptables: addr: ''
            ${iptables} -D FORWARD -i wg0 -j ACCEPT
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
