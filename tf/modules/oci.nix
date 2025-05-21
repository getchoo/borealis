{ config, lib, ... }:

let
  cfg = config.borealis.oci;

  settingsResourceMap = {
    availabilityDomains = "oci_identity_availability_domains";
    identityCompartments = "oci_identity_compartment";
    instances = "oci_core_instance";
    securityLists = "oci_core_security_list";
    subnets = "oci_core_subnet";
    vcns = "oci_core_vcn";
  };

  freeformAttrsOption = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule { freeformType = lib.types.attrsOf (lib.types.attrsOf lib.types.anything); }
    );
  };
in

{
  options.borealis = {
    oci = lib.mapAttrs (_: _: freeformAttrsOption) settingsResourceMap;
  };

  config = {
    resource = lib.mkMerge (
      lib.mapAttrsToList (
        opt: resource:
        lib.mkIf (cfg.${opt} != null) {
          ${resource} = lib.mapAttrs lib.const cfg.${opt};
        }
      ) settingsResourceMap
    );
  };
}
