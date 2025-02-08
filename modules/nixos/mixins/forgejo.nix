{ config, lib, ... }:

let
  cfg = config.mixins.forgejo;
in

{
  options.mixins.forgejo = {
    enable = lib.mkEnableOption "default configuration for Forgejo";
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;

      database = {
        type = "postgres";
      };

      settings = {
        server = {
          PROTOCOL = "http+unix";
          DOMAIN = "git." + config.networking.domain;
          ROOT_URL = "https://" + config.services.forgejo.settings.server.DOMAIN + "/";

          DISABLE_SSH = true;
        };

        oauth2_client = {
          ENABLE_AUTO_REGISTRATION = true;
        };

        service = {
          DISABLE_REGISTRATION = lib.mkDefault true;
        };

        packages = {
          ENABLED = false;
        };

        actions = {
          ENABLED = false;
        };
      };
    };
  };
}
