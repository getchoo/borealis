{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.systemd-discord-notifier;

  unitFormat = pkgs.formats.systemd;
  systemVendorDir = "lib/systemd/system";

  systemdPackage = pkgs.linkFarm "systemd-discord-notifier-unit-overrides" (
    {
      # Base override for all services
      "${systemVendorDir}/service.d/discord-notify-failure.conf" =
        unitFormat.generate "systemd-discord-notifier.conf"
          {
            Unit = {
              OnFailure = [ "discord-notify-failure@%N.service" ];
            };
          };
    }
    // lib.listToAttrs (
      map (
        name: lib.nameValuePair "${systemVendorDir}/${name}.d/discord-notify-failure.conf" pkgs.emptyFile
      ) cfg.excludeServices
    )
  );
in

{
  options = {
    services.systemd-discord-notifier = {
      enable = lib.mkEnableOption "systemd-discord-notifier";

      content = lib.mkOption {
        type = lib.types.str;
        default = "# 🚨 %i.service failed! 🚨";
        description = "String template for webhook message content.";
      };

      excludeServices = lib.mkOption {
        type = lib.types.listOf utils.systemdUtils.lib.unitNameType;
        default = [ ];
        description = "List of service names to exclude from notifications.";
      };

      webhookURLFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to a file containing the webhook URL.

          NOTE: This is required.
          If not set declaratively, use `systemctl edit` and pass a `webhook-url` credential.
        '';
        example = "/run/secrets/discordWebhookURL";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.systemd-discord-notifier = {
      excludeServices = [ "discord-notify-failure@.service" ];
    };

    systemd = {
      packages = [ systemdPackage ];

      services."discord-notify-failure@" = {
        description = "Notify of service failures on Discord.";

        after = [ "network.target" ];

        path = [ pkgs.curl ];

        script = ''
          systemd-creds cat webhook-url | xargs curl -X POST -F "content=$CONTENT"
        '';

        enableStrictShellChecks = true;

        environment = {
          CONTENT = cfg.content;
        };

        serviceConfig = {
          Type = "oneshot";
          # TODO: Why doesn't AssertCredential work with this?
          LoadCredential = lib.mkIf (cfg.webhookURLFile != null) "webhook-url:${cfg.webhookURLFile}";
          # TODO: Harden
          DynamicUser = true;
        };
      };
    };
  };
}
