# Create everything from an existing tenancy

resource "oci_identity_compartment" "borealis" {
  compartment_id = var.oracle_tenancy_ocid
  description    = "For my personal infra"
  name           = "borealis"
}

data "oci_identity_availability_domains" "borealis" {
  compartment_id = oci_identity_compartment.borealis.id
}

output "borealis-first-availability-domain" {
  value = data.oci_identity_availability_domains.borealis.availability_domains[0].name
}

resource "oci_core_vcn" "borealis" {
  compartment_id = oci_identity_compartment.borealis.id
  display_name   = "borealis"
}

resource "oci_core_subnet" "borealis_global" {
  cidr_block     = "10.0.0.0/24"
  compartment_id = oci_core_vcn.borealis.compartment_id
  vcn_id         = oci_core_vcn.borealis.id

  display_name = "global"
}

resource "oci_core_security_list" "borealis_global" {
  compartment_id = oci_core_vcn.borealis.compartment_id
  vcn_id         = oci_core_vcn.borealis.id

  display_name = "default"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol = "1"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol = "1"
    source   = "10.0.0.0/16"
  }
}
