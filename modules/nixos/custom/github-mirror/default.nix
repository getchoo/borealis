{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.borealis.github-mirror;
  cgitInstance = config.services.cgit.${cfg.hostname};

  update-mirror =
    pkgs.runCommand "update-mirror"
      {
        nativeBuildInputs = [ pkgs.patsh ];

        buildInputs = [
          config.programs.git.package
          pkgs.curl
          pkgs.jq
        ];
      }
      ''
        patsh -s ${builtins.storeDir} ${./update-mirror.sh} $out
        chmod 755 $out
        patchShebangs $out
      '';
in

{
  options.borealis.github-mirror = {
    enable = lib.mkEnableOption "the github-mirror service";

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of the cgit service to create";
      example = lib.literalExpression "git.example.com";
    };

    mirroredUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of GitHub users to mirror repositories for";
      example = lib.literalExpression ''[ "edolstra" ]'';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.mirroredUsers != [ ];
        message = "`borealis.github-mirror.mirroredUsers` must have at least one user";
      }
    ];

    services.cgit.${cfg.hostname} = {
      enable = true;

      scanPath = "/var/lib/cgit/${cfg.hostname}";
      settings = {
        robots = "none"; # noindex, nofollow
      };

      user = "cgit";
      group = "cgit";
    };

    systemd = {
      services.github-mirror = {
        description = "Mirror a GitHub repository";

        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        script = toString (
          [
            "exec"
            (toString update-mirror)
            "--directory"
            cgitInstance.scanPath
          ]
          ++ cfg.mirroredUsers
        );

        serviceConfig = {
          Type = "oneshot";
          User = cgitInstance.user;
          Group = cgitInstance.group;
        };
      };

      timers.github-mirror = {
        description = "Hourly timer for %N";
        timerConfig.OnCalendar = "hourly";
      };

      tmpfiles.settings."10-github-mirror" = {
        ${cgitInstance.scanPath}.d = {
          inherit (cgitInstance) user group;
        };
      };
    };
  };
}
