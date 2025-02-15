{
  config,
  lib,
  secretsDir,
  ...
}:

{
  config = lib.mkMerge [
    {
      services.grafana = {
        settings = {
          analytics = {
            feedback_links_enabled = false;
            reporting_enabled = false;
          };

          "auth.anonymous" = {
            enable = true;
            org_role = "Viewer";
          };

          server = {
            http_port = 6000;

            domain = lib.mkDefault ("grafana." + config.networking.domain);
            enable_gzip = true;
            enforce_domain = true;
            root_url = "https://" + config.services.grafana.settings.server.domain + "/";
          };
        };
      };
    }

    (lib.mkIf config.services.kanidm.enableServer {
      services.grafana = {
        settings = {
          "auth.basic".enabled = false;

          "auth.generic_oauth" = {
            enabled = true;

            name = "Kanidm";
            client_id = "grafana";
            client_secret = "$__file{${config.age.secrets.grafanaKanidm.path}}";
            scopes = "openid,profile,email,groups";
            auth_url = config.services.kanidm.serverSettings.origin + "/ui/oauth2";
            token_url = config.services.kanidm.serverSettings.origin + "/oauth2/token";
            api_url = config.services.kanidm.serverSettings.origin + "/oauth2/openid/grafana/userinfo";
            use_pkce = true;
            use_refresh_token = true;

            allow_assign_grafana_admin = true;
            allow_sign_up = true;
            groups_attribute_path = "groups";
            login_attribute_path = "preferred_username";
            role_attribute_path = "contains(grafana_role[*], 'GrafanaAdmin') && 'GrafanaAdmin' || contains(grafana_role[*], 'Admin') && 'Admin' || contains(grafana_role[*], 'Editor') && 'Editor' || 'Viewer'";
          };
        };
      };
    })

    (lib.mkIf (config.services.grafana.enable && config.services.kanidm.enableServer) {
      age.secrets.grafanaKanidm = {
        file = secretsDir + "/grafanaKanidmSecret.age";
        owner = config.users.users.grafana.name;
        group = config.users.groups.grafana.name;
      };
    })
  ];
}
