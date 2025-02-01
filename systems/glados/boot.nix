{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  environment.systemPackages = [
    # manual lanzaboote maintenance (NOTE: i have not actually used this since ~2022)
    pkgs.sbctl
    # TODO: is this actually required for using `tpm2-device=auto` to unlock LUKS volumes in initrd? probably
    pkgs.tpm2-tss
  ];

  boot = {
    initrd.systemd.enable = true; # for unlocking luks root with tpm2

    kernelPackages = pkgs.linuxKernel.packages.linux_6_11;

    kernelParams =
      [
        "amd_pstate=active"
      ]
      # Don't use GSP Firmware on proprietary driver
      # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/693
      ++ lib.optional (!config.hardware.nvidia.open) "nvidia.NVreg_EnableGpuFirmware=0";

    loader.systemd-boot.enable = lib.mkForce false; # lanzaboote replaces this

    lanzaboote = {
      enable = true;

      pkiBundle = "/etc/secureboot";

      settings = {
        console-mode = "auto";
        editor = false;
        timeout = 0;
      };
    };

    supportedFilesystems = [ "ntfs" ]; # for game drive
  };
}
