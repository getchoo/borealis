{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.systemd-discord-notifier;

  # Add our template unit to each service by default if enabled
  systemdServicesSubmodule = {
    config = lib.mkIf cfg.enable {
      onFailure = lib.mkDefault [ "discord-notify-failure@%N.service" ];
    };
  };
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

    systemd.services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule systemdServicesSubmodule);
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."discord-notify-failure@" = {
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
}
