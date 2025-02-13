{ config, lib, ... }:

{
  config = lib.mkIf config.zramSwap.enable {
    # Optimize system for zram
    # https://github.com/pop-os/default-settings/pull/163
    # https://wiki.archlinux.org/title/Zram#Multiple_zram_devices
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
  };
}
