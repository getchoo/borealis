{ lib, ... }:

let
  borealisComparmentId = lib.tfRef "oci_identity_compartment.borealis.id";
in

{
  data = {
    oci_identity_availability_domains = {
      borealis = {
        compartment_id = borealisComparmentId;
      };
    };
  };

  borealis.oci = {
    identityCompartment = {
      borealis = {
        compartment_id = lib.tfRef "var.oracle_tenancy_ocid";
        description = "For my personal infra";
        name = "borealis";
      };
    };

    vcns = {
      borealis = {
        compartment_id = borealisComparmentId;
        display_name = "borealis";
      };
    };

    securityLists = {
      borealis_global = {
        compartment_id = borealisComparmentId;
        vcn_id = lib.tfRef "oci_core_vcn.borealis.id";

        display_name = "default";

        egress_security_rules = [
          {
            destination = "0.0.0.0/0";
            protocol = "all";
          }
        ];

        ingress_security_rules = [
          {
            icmp_options = [
              {
                code = "4";
                type = "3";
              }
            ];
            protocol = "1";
            source = "0.0.0.0/0";
          }

          {
            icmp_options = [
              {
                code = "-1";
                type = "3";
              }
            ];
            protocol = "1";
            source = "10.0.0.0/16";
          }

          {
            description = "Allow HTTP traffic";

            protocol = "6";
            source = "0.0.0.0/0";

            tcp_options = {
              min = 80;
              max = 80;
            };
          }

          {
            description = "Allow HTTPS traffic";

            protocol = "6";
            source = "0.0.0.0/0";

            tcp_options = {
              min = 443;
              max = 443;
            };
          }

          {
            description = "Allow traffic";

            protocol = "6";
            source = "0.0.0.0/0";

            tcp_options = {
              min = 50300;
              max = 50300;
            };
          }
        ];
      };
    };

    subnets = {
      borealis_global = {
        cidr_block = "10.0.0.0/24";
        compartment_id = borealisComparmentId;
        vcn_id = lib.tfRef "oci_core_vcn.borealis.id";

        display_name = "global";
        security_list_ids = [ (lib.tfRef "oci_core_security_list.borealis_global.id") ];
      };
    };
  };
}
