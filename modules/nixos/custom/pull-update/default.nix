{
  config,
  lib,
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

  flagsToPass = lib.foldlAttrs (
    acc: setting: flags:
    acc ++ lib.optionals (settings.${setting} != null) flags
  ) [ ] flagsForSetting;

  timerSubmoduleType = options.systemd.timers.type.nestedTypes.elemType;
  timerConfigType = (timerSubmoduleType.getSubOptions [ ]).timerConfig.type;

  nixEnvironment =
    config.nix.envVars
    // config.networking.proxy.envVars
    // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
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
        flags = [ settings.operation ] ++ flagsToPass;
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

            environment = nixEnvironment;
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
            };
          };

          nixos-pull-update-rollback = {
            description = "Rollback a NixOS configuration update";

            environment = nixEnvironment;
            inherit (config.systemd.services.nixos-pull-update)
              enableStrictShellChecks
              ;

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${lib.getExe nixos-rebuild} ${settings.operation} --rollback";
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
