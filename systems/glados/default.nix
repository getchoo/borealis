{ config, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default
  ];

  borealis = {
    profiles.desktop.enable = true;

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
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "575.64.05";
      sha256_64bit = "sha256-hfK1D5EiYcGRegss9+H5dDr/0Aj9wPIJ9NVWP3dNUC0=";
      sha256_aarch64 = "sha256-GRE9VEEosbY7TL4HPFoyo0Ac5jgBHsZg9sBKJ4BLhsA=";
      openSha256 = "sha256-mcbMVEyRxNyRrohgwWNylu45vIqF+flKHnmt47R//KU=";
      settingsSha256 = "sha256-o2zUnYFUQjHOcCrB0w/4L6xI1hVUXLAWgG2Y26BowBE=";
      persistencedSha256 = "sha256-2g5z7Pu8u2EiAh5givP5Q1Y4zk4Cbb06W37rf768NFU=";
    };
  };

  networking = {
    hostName = "glados";
    networkmanager.enable = true;
  };

  nixpkgs.overlays = [
    (_: prev: {
      chromium = prev.chromium.override (prev': {
        # NOTE: If this breaks, look at https://github.com/elFarto/nvidia-vaapi-driver/issues/5
        commandLineArgs = prev'.commandLineArgs or [ ] ++ [
          "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks"
        ];
      });
    })
  ];

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
  };

  services = {
    desktopManager.gnome.enable = true;

    flatpak.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;

    xserver = {
      enable = true;

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
