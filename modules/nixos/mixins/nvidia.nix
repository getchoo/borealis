{ config, lib, ... }:

let
  cfg = config.hardware.nvidia;

  # Unlike Nixpkgs, I know all of my GPUs should prefer the open modules after 560
  useOpenModulesByDefault = lib.versionAtLeast config.hardware.nvidia.package.version "560";
in

{
  options.hardware.nvidia = {
    nvk.enable = lib.mkEnableOption "an NVK specialisation";
  };

  config = lib.mkMerge [
    {
      hardware.nvidia = {
        open = useOpenModulesByDefault;
        # We usually want this to make suspend, etc. work
        powerManagement.enable = lib.mkDefault true;
      };
    }

    (lib.mkIf cfg.nvk.enable {
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
    })

    (lib.mkIf config.traits.containers.enable {
      hardware.nvidia-container-toolkit.enable = true;
    })
  ];
}
