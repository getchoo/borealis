{ config, lib, ... }:

let
  cfg = config.borealis.cloudflare.pages;

  freeformSubmodule = {
    freeformType = lib.types.attrsOf lib.types.anything;
  };
in

{
  options.borealis = {
    cloudflare.pages = {
      domains = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule freeformSubmodule);
        default = { };
      };

      projects = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule freeformSubmodule);
        default = { };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.domains != { }) {
      resource.cloudflare_pages_domain = lib.mapAttrs lib.const cfg.domains;
    })

    (lib.mkIf (cfg.projects != { }) {
      resource.cloudflare_pages_project = lib.mapAttrs lib.const cfg.projects;
    })
  ];
}
