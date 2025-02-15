{
  config,
  lib,
  inputs,
  ...
}:

let
  usesNodeExporter = system: system.config.services.prometheus.exporters.node.enable;

  nodeExporterFrom =
    system:
    "http://${system.config.networking.hostName}:${toString system.config.services.prometheus.exporters.node.port}";

  toNodeStaticConfig = system: {
    targets = [ (nodeExporterFrom system) ];
    labels.type = "node";
  };

  remoteNodes = lib.mapAttrsToList (lib.const toNodeStaticConfig) (
    lib.filterAttrs (lib.const usesNodeExporter) inputs.self.nixosConfigurations
  );
in

{
  borealis = {
    victorialogs = {
      enable = true;
    };
  };

  services = {
    journald.upload.enable = true;

    prometheus.exporters.node.enable = true;

    victoriametrics = {
      enable = true;

      retentionPeriod = "7d";

      prometheusConfig = {
        scrape_configs = [
          {
            job_name = "forgejo";
            metrics_path = "/metrics";
            static_configs = [
              {
                targets = [
                  "http://${config.services.forgejo.settings.server.HTTP_ADDR}:${toString config.services.forgejo.settings.server.HTTP_PORT}"
                ];
                labels.type = "forgejo";
              }
            ];
          }

          {
            job_name = "miniflux";
            metrics_path = "/metrics";
            static_configs = [
              {
                targets = [ "http://${config.services.miniflux.config.LISTEN_ADDR}" ];
                labels.type = "miniflux";
              }
            ];
          }

          {
            job_name = "node-exporter";
            metrics_path = "/metrics";
            static_configs = remoteNodes;
          }

          {
            job_name = "victoria-logs";
            metrics_path = "/metrics";
            static_configs = [
              {
                targets = [ "localhost:9428" ];
                labels.type = "victoria-logs";
              }
            ];
          }

          {
            job_name = "victoria-metrics";
            metrics_path = "/metrics";
            static_configs = [
              {
                targets = [ "localhost${config.services.victoriametrics.listenAddress}" ];
                labels.type = "victoria-logs";
              }
            ];
          }
        ];
      };
    };
  };
}
