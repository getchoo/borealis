{
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
            job_name = "node-exporter";
            metrics_path = "/metrics";
            static_configs = remoteNodes;
          }
        ];
      };
    };
  };
}
