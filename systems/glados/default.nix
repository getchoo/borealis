{ config, inputs, ... }:
{
  imports = [
    ./boot.nix
    ./hardware-configuration.nix

    inputs.self.nixosModules.default
  ];

  profiles.personal.enable = true;

  desktop = {
    enable = true;
    gnome.enable = true;
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

  networking = {
    hostName = "glados";
    networkmanager.enable = true;
  };

  programs = {
    steam.enable = true;
  };

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
  };

  services = {
    flatpak.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
  };

  system.stateVersion = "23.11";

  traits = {
    arm-builder.enable = true;
    containers.enable = true;
    determinate.enable = true;
    mac-builder.enable = true;
    nvidia = {
      enable = true;
      nvk.enable = false;
    };
    tailscale.enable = true;
    zram.enable = true;
  };
}
