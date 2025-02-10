{
  config,
  lib,
  ...
}:

{
  boot = {
    kernelParams =
      [
        "amd_pstate=active"
      ]
      # Don't use GSP Firmware on proprietary driver
      # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/693
      ++ lib.optional (!config.hardware.nvidia.open) "nvidia.NVreg_EnableGpuFirmware=0";

    lanzaboote = {
      enable = true;
    };
  };
}
