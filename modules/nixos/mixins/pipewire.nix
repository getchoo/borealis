{ config, lib, ... }:

{
  config = lib.mkMerge [
    {
      services.pipewire = lib.mkDefault {
        wireplumber.enable = true;
        alsa.enable = true;
        jack.enable = true;
        pulse.enable = true;
      };
    }

    (lib.mkIf config.services.pipewire.enable {
      security.rtkit.enable = true;
    })
  ];
}
