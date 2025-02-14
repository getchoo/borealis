{ config, lib, ... }:

let
  isNvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;

  # Unlike Nixpkgs, I know all of my GPUs should prefer the open modules after 560
  useOpenModulesByDefault = lib.versionAtLeast config.hardware.nvidia.package.version "560";
in

{
  config = lib.mkMerge [
    {
      hardware.nvidia = {
        open = useOpenModulesByDefault;
        # We usually want this to make suspend, etc. work
        powerManagement.enable = lib.mkDefault true;
      };
    }

    (lib.mkIf config.virtualisation.podman.enable {
      hardware = {
        nvidia-container-toolkit.enable = true;
      };
    })

    (lib.mkIf (isNvidiaEnabled && !config.hardware.nvidia.open) {
      # Don't use GSP Firmware on proprietary driver

      # TODO: Remove when the following is fixed
      # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/693
      boot.kernelParams = [
        "nvidia.NVreg_EnableGpuFirmware=0"
      ];
    })
  ];
}
