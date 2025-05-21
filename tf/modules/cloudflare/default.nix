{ config, lib, ... }:

let
  cfg = config.borealis.cloudflare.settings;

  nullableBool = lib.types.nullOr lib.types.bool;

  cloudflareSettings =
    { name, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
        };

        zoneId = lib.mkOption {
          type = lib.types.str;
        };

        authenticatedOriginPulls = lib.mkEnableOption "Authenticated Origin Pulls" // {
          type = nullableBool;
        };

        zoneDNSSEC = lib.mkEnableOption "DNSSEC for the entire zone" // {
          type = nullableBool;
        };

        zoneSettingsOverride = lib.mkOption {
          type = lib.types.submodule { freeformType = lib.types.attrsOf lib.types.anything; };
          deafault = { };
        };
      };
    };
in

{
  imports = [
    ./dns.nix
    ./pages.nix
    ./rulesets.nix
  ];

  options.borealis = {
    cloudflare.settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule cloudflareSettings);
      default = { };
      description = "Cloudflare settings for a given zone.";
    };
  };

  config = lib.mkIf (cfg != { }) {
    resource = lib.mkMerge (
      lib.mapAttrsToList (name: cfg: {
        cloudflare_authenticated_origin_pulls.${name} = lib.mkIf (cfg.authenticatedOriginPulls != null) {
          zone_id = cfg.zoneId;
          enabled = cfg.authenticatedOriginPulls;
        };

        cloudflare_zone_dnssec.${name} = lib.mkIf (cfg.zoneDNSSEC != null) {
          zone_id = cfg.zoneId;
        };

        cloudflare_zone_settings_override.${name} = lib.mkIf (cfg.zoneSettingsOverride != null) {
          zone_id = cfg.zoneId;

          settings = cfg.zoneSettingsOverride;
        };
      }) cfg
    );
  };
}
