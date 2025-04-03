{ modulesPath, inputs, ... }:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./hardware-configuration.nix
    ./moyai.nix
    ./nixpkgs-tracker-bot.nix

    inputs.self.nixosModules.default
  ];

  borealis = {
    profiles.server.enable = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  catppuccin = {
    forgejo.enable = true;
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
    forgejo.enable = true;

    hedgedoc.enable = true;

    kanidm = {
      enableClient = true;
      enableServer = true;
    };

    miniflux.enable = true;

    nginx.enable = true;
  };

  system.stateVersion = "23.05";
}
