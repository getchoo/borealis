{ modulesPath, inputs, ... }:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./hardware-configuration.nix
    ./forgejo.nix
    ./grafana.nix
    ./kanidm.nix
    ./miniflux.nix
    ./moyai.nix
    ./nixpkgs-tracker-bot.nix
    ./victoria-metrics.nix

    inputs.self.nixosModules.default
  ];

  borealis = {
    profiles.server.enable = true;
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
    hedgedoc.enable = true;
    nginx.enable = true;
  };

  system.stateVersion = "23.05";
}
