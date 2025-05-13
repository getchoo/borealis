{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.borealis.tailscale.tailnets;

  aclFormat = pkgs.formats.json { };

  tailnetSubmodule =
    { name, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
        };

        acl = lib.mkOption {
          inherit (aclFormat) type;
          default = { };
        };

        magicDNS = lib.mkEnableOption "Magic DNS for your tailnet" // {
          type = lib.types.nullOr lib.types.bool;
        };

        taggedDevices = lib.mkOption {
          type = lib.types.attrsOf (lib.types.listOf lib.types.str);
          default = { };
        };
      };
    };
in

{
  options.borealis = {
    tailscale.tailnets = {
      type = lib.types.attrsOf (lib.types.submodule tailnetSubmodule);
      default = { };
    };
  };

  config = lib.mkIf (cfg != { }) (
    lib.mkMerge (
      lib.flatten (
        lib.mapAttrsToList (name: cfg: [
          (lib.mkIf (cfg.acl != { }) {
            resource.tailscale_acl."${name}_acl" = {
              acl = lib.generators.toJSON { } cfg.acl;
            };
          })

          (lib.mkIf (cfg.magicDNS != null) {
            resource.tailscale_dns_preferences.${name} = {
              magic_dns = cfg.magicDNS;
            };
          })

          (lib.mkIf (cfg.taggedDevices != { }) {
            local."${name}_devices" = lib.attrValues cfg.taggedDevices;

            data.tailscale_device."${name}_devices" = {
              for_each = "\${{ toset(local.${cfg.name}_devices) }}";

              inherit (cfg) name;
              waitFor = "60s";
            };
          })

          (lib.mkIf (cfg.taggedDevices != { }) {
            local = lib.mapAttrs' (tag: lib.nameValuePair "${name}_${tag}");

            resource.tailscale_device_tags = lib.mapAttrs (tag: _: {
              for_each = "\${{ toset(local.${name}_${cfg.tag}) }}";

              device_id = lib.tfRef "data.tailscale_device.${name}_devices[each.key].id";
              tags = [ "tag:${tag}" ];
            }) cfg.taggedDevices;
          })
        ]) cfg
      )
    )
  );
}
