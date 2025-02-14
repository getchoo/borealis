{ config, lib, ... }:

{
  config = lib.mkMerge [
    {
      services.pipewire = lib.mkDefault {
        alsa.enable = true;
        jack.enable = true;
        pulse.enable = true;
      };
    }

    (lib.mkIf config.services.pipewire.enable {
      security.rtkit.enable = true;

      services.pipewire = {
        wireplumber.enable = true;
      };
    })
  ];
}
