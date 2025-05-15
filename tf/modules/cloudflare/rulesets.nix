{ config, lib, ... }:

let
  cfg = config.borealis.cloudflare.rulesets;

  rulesetSubmodule = {
    freeformType = lib.types.attrsOf lib.types.anything;
  };

  domainSubmodule = {
    options = {
      ruleset = lib.mkOption {
        type = lib.types.submodule rulesetSubmodule;
        default = { };
      };

      zoneId = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
in

{
  options.borealis = {
    cloudflare.rulesets = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule domainSubmodule);
      default = { };
      description = "Attribute set describing Cloudflare zones and their rulesets.";
    };
  };

  config = lib.mkIf (cfg != { }) {
    resource.cloudflare_ruleset = lib.mapAttrs (lib.const (
      cfg: cfg.ruleset // { zone_id = cfg.zoneId; }
    )) cfg;
  };
}
