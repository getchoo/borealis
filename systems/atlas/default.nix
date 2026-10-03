{
  config,
  lib,
  modulesPath,
  inputs,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./hardware-configuration.nix
    ./moyai.nix
    ./nixpkgs-tracker-bot.nix
    ./wireguard.nix

    inputs.self.nixosModules.default
  ];

  borealis = {
    profiles.server.enable = true;

    rime = {
      enable = true;

      domain = "rime." + config.networking.domain;
      nginx = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    domain = "getchoo.com";
    hostName = "atlas";

    firewall.allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
    ];
  };

  nixpkgs.hostPlatform = "aarch64-linux";

  services = {
    nginx = {
      enable = true;

      virtualHosts."static.${config.networking.domain}" = {
        root = "/var/www";
      };
    };

    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
      };
    };
  };

  users.users = lib.genAttrs [ config.networking.hostName "root" ] (
    lib.const {
      openssh.authorizedKeys.keys = [
        # Personal 1Password
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBzp61t3KlcZZorMGzCHJJmiCoAEJsdHgYww80LmwkPd"
      ];
    }
  );

  system.stateVersion = "23.05";
}
