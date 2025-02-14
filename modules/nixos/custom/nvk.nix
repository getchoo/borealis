{ config, lib, ... }:

let
  cfg = config.borealis.nvk;
in

{
  options.borealis.nvk = {
    enable = lib.mkEnableOption "an NVK specialisation";
  };

  config = lib.mkIf cfg.enable {
    specialisation = {
      nvk.configuration = {
        boot = {
          # required for GSP firmware
          kernelParams = [ "nouveau.config=NvGspRm=1" ];
          # we want early KMS
          # https://wiki.archlinux.org/title/Kernel_mode_setting#Early_KMS_start
          initrd.kernelModules = [ "nouveau" ];
        };

        hardware = {
          graphics.extraPackages = lib.mkForce [ ];
          nvidia-container-toolkit.enable = lib.mkForce false;
        };

        services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];

        system.nixos.tags = [ "with-nvk" ];
      };
    };
  };
}
