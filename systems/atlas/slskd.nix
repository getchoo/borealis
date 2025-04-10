{
  config,
  lib,
  pkgs,
  ...
}:

let
  beetsConfigFormat = pkgs.formats.yaml { };
  beetsSettings = {
    directory = "/srv/music";
    library = "/var/lib/beets.db";

    import = {
      move = true;
    };

    paths = {
      default = "$albumartist/$album%aunique{}/$track $title";
      singleton = "$albumartist/singles/$title";
      comp = "$albumartist/compilations/$album%aunique{}/$track $title";
    };
  };
  beetsConfigFile = beetsConfigFormat.generate "beets-config.yaml" beetsSettings;

  beetsImportScript = pkgs.writeShellApplication {
    name = "beets-import-slskd";

    runtimeInputs = [
      pkgs.beets
      pkgs.jq
    ];

    text = ''
      jq --raw-output '.localFilename' <<< "$SLSKD_SCRIPT_DATA" \
        | xargs beet --config ${beetsConfigFile} import --noautotag
    '';
  };
in

{
  services = {
    slskd = {
      enable = true;

      package = pkgs.slskd.overrideAttrs (old: {
        patches = old.patches or [ ] ++ [
          (pkgs.fetchpatch {
            name = "slskd-better-scripts.patch";
            url = "https://github.com/slskd/slskd/pull/1292.patch";
            hash = "sha256-HCgHjFcvjkNgLg8Z+VvSWZpQ6mrmQqYU0PQpyw9CBmE=";
          })
        ];
      });

      openFirewall = true;
      domain = null;

      environmentFile = pkgs.emptyFile; # Dumb hack because I manage this locally

      settings = {
        directories = {
          downloads = "/var/lib/slskd/downloads";
        };

        integration = {
          scripts = {
            beets = {
              on = [ "DownloadFileComplete" ];
              run = lib.getExe beetsImportScript;
            };
          };
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
