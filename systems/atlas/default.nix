{ modulesPath, inputs, ... }:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./hardware-configuration.nix
    ./forgejo.nix
    ./miniflux.nix
    ./moyai.nix
    ./nixpkgs-tracker-bot.nix

    inputs.self.nixosModules.default
  ];

  profiles.server.enable = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    domain = "getchoo.com";
    hostName = "atlas";
  };

  nixpkgs.hostPlatform = "aarch64-linux";

  services = {
    nginx.enable = true;
  };

  system.stateVersion = "23.05";
}
