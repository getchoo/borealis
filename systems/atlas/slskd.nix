{ config, ... }:

{
  services = {
    slskd = {
      enable = true;

      openFirewall = true;
      domain = null;

      environmentFile = "/etc/slskd.conf";

      settings = {
        directories = {
          downloads = "/var/lib/slskd/downloads";
        };

        shares = {
          directories = [ config.services.navidrome.settings.MusicFolder ];
        };

        soulseek = {
          description = "getchoo uh huh";
        };
      };
    };
  };
}
