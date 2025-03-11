{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default
    inputs.lix-module.nixosModules.default
  ];

  borealis = {
    profiles.personal.enable = true;

    remote-builders = {
      enable = true;

      builders = {
        atlas = true;
        macstadium = true;
      };
    };
  };

  boot = {
    kernelParams = [
      "amd_pstate=active"
    ];

    lanzaboote = {
      enable = true;
    };
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/693
    open = lib.mkForce false;
  };

  networking = {
    hostName = "glados";
    networkmanager.enable = true;
  };

  nixpkgs.overlays = [
    # TODO: Remove when `programs.chromium.package` exists
    (_: prev: {
      chromium = prev.chromium.override {
        commandLineArgs = [ "--enable-features=VaapiOnNvidiaGPUs,AcceleratedVideoDecodeLinuxGL" ];
      };
    })
  ];

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
  };

  services = {
    flatpak.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;

    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;

      videoDrivers = [ "nvidia" ];
    };
  };

  swapDevices = [
    {
      # WARN: Don't set size!
      #
      # We're on btrfs and the NixOS module won't handle it properly.
      # Make it 4GB or so manually with
      # `btrfs filesystem mkswapfile --size 4g --uuid clear /swap/swapfile` in it's own subvol
      device = "/swap/swapfile";
    }
  ];

  system.stateVersion = "23.11";

  virtualisation = {
    oci-containers.backend = "podman";
    podman.enable = true;
  };

  zramSwap.enable = true;
}
