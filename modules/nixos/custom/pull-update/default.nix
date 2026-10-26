{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.borealis.pull-update;
  inherit (cfg) settings;
  inherit (config.system.build) nixos-rebuild;

  flagsForSetting = {
    flakeref = [
      "--flake"
      settings.flakeref
    ];

    file = [
      "--file"
      settings.file
    ];

    attr = [
      "--attr"
      settings.attr
    ];
  };

  timerSubmoduleType = options.systemd.timers.type.nestedTypes.elemType;
  timerConfigType = (timerSubmoduleType.getSubOptions [ ]).timerConfig.type;

  sharedEnv =
    config.nix.envVars
    // config.networking.proxy.envVars
    // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";

      REBUILD_OPERATION = settings.operation;
      STATE_FILE = "/var/lib/nixos-update.state";
    };
in

{
  options.borealis.pull-update = {
    enable = lib.mkEnableOption "automatic updates being pulled from the selected source";

    timer = lib.mkOption {
      type = timerConfigType;
      default = {
        OnCalendar = "03:00";
        RandomizedDelaySec = "5min";
        Persistent = true;
      };
      description = "Attribute set of {manpage}`systemd.time(7)` options to configure the service timer.";
      example = {
        OnCalendar = "daily";
        RandomizedDelaySec = "45min";
      };
    };

    settings = {
      operation = lib.mkOption {
        type = lib.types.str;
        default = "switch";
        description = "`nixos-rebuild` operation to perform (switch, boot, etc.).";
        example = "boot";
      };

      flakeref = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Build the new configuration from this flake reference.";
        example = "github:example/flake#my-system";
      };

      file = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Build the new configuration from this file.";
        example = "https://github.com/example/nix-config/archive/main.tar.gz";
      };

      attr = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Build the new configuration from this attribute in `cfg.file` or `<nixos-config>`.";
      };

      flags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "--no-reexec" ];
        description = "Any additional flags to pass to `nixos-rebuild`.";
      };

      runGC = lib.mkEnableOption "GC after a successful update";
    };
  };

  config = lib.mkMerge [
    {
      borealis.pull-update.settings = {
        flags = lib.foldlAttrs (
          acc: setting: flags:
          acc ++ lib.optionals (settings.${setting} != null) flags
        ) [ ] flagsForSetting;
      };
    }

    (lib.mkIf cfg.enable {
      systemd = {
        services = {
          nixos-pull-update = {
            description = "Update NixOS configuration";

            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];

            restartIfChanged = false;
            startAt = cfg.timer.OnCalendar;

            environment = sharedEnv;
            path = [ nixos-rebuild ];

            enableStrictShellChecks = true;
            scriptArgs = lib.escapeShellArgs settings.flags;
            script = lib.readFile ./update.sh;

            serviceConfig = {
              Type = "oneshot";
            };

            unitConfig = {
              OnSuccess = lib.mkIf settings.runGC "nix-gc.service";
              OnFailure = "nixos-pull-update-rollback.service";
              X-StopOnRemoval = false;
            };
          };

          nixos-pull-update-rollback = {
            description = "Rollback a NixOS configuration update";

            inherit (config.systemd.services.nixos-pull-update)
              enableStrictShellChecks
              restartIfChanged
              ;

            environment = sharedEnv;
            path = [
              nixos-rebuild
              pkgs.moreutils
            ];

            script = lib.readFile ./rollback.sh;

            serviceConfig = {
              Type = "oneshot";
            };
          };
        };

        timers.nixos-pull-update = {
          timerConfig = cfg.timer;
        };
      };
    })
  ];
}
