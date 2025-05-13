{ config, lib, ... }:

let
  cfg = config.borealis.dns;

  dnsSubmodule =
    { config, ... }:

    {
      options = {
        proxied = lib.mkDefault {
          type = lib.types.bool;
          default = config.type != "TXT";
        };
      };
    };

  domainSubmodule = {
    options = {
      records = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule dnsSubmodule);
      };

      zoneId = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
in

{
  options.borealis.dns = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule domainSubmodule);
  };

  config = lib.mkIf (cfg != { }) {
    locals = lib.mapAttrs (lib.const (cfg: lib.mapAttrsToList lib.const cfg.records)) cfg;

    resource.cloudflare_record = lib.mapAttrs (lib.const (cfg: {
      for_each = "\${{ for record in local.${cfg.name}_records : \"${cfg.name}-${cfg.type}\" }}";

      zone_id = cfg.zoneId;
      name = lib.tf.ref "each.value.name";
      type = lib.tf.ref "each.value.type";
      content = lib.tf.ref "each.value.content";
      proxied = lib.tf.ref "each.value.proxied";
    })) cfg;
  };
}
