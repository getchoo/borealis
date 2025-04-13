{ pkgs, ... }:

let
  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "beets-config.yaml" settings;

  settings = {
    directory = "/srv/music";
    library = "/var/lib/beets.db";

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
