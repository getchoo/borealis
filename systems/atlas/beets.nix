{ pkgs, ... }:

let
  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "beets-config.yaml" settings;

  settings = {
    directory = "/srv/music";
    library = "/var/lib/beets.db";

    aunique = {
      disambiguators = toString [
        "albumtype"
        "releasegroupdisambig"
        "albumdisambig"
        "year"
        "label"
        "catalognum"
      ];
    };

    plugins = toString [
      "badfiles"
      "duplicates"
      "fetchart"
      "info"
      "lyrics"
      "mbsync"
      "scrub"
    ];

    badfiles = {
      check_on_import = true;
    };

    duplicates = {
      delete = true;
      full = true;
      merge = true;
      tiebreak.items = [
        "bitrate"
        "samplerate"
      ];
    };

    fetchart = {
      auto = true;
    };

    lyrics = {
      auto = true;
    };

    scrub = {
      auto = true;
    };

    import = {
      move = true;
      resume = true;
      incremental = true;
      incremental_skip_later = true;
      timid = false;
      log = "/var/log/beets.log";
    };

    paths = {
      default = "$albumartist/$album%aunique{}/$track $title";
      singleton = "$albumartist/singles/$title";
      comp = "$albumartist/compilations/$album%aunique{}/$track $title";
    };
  };

  beetsGlobalScript = pkgs.writeShellApplication {
    name = "beets-global";

    runtimeInputs = [ pkgs.beets ];

    text = ''
      beet --config ${settingsFile} "$@"
    '';
  };
in

{
  environment.systemPackages = [ beetsGlobalScript ];
}
