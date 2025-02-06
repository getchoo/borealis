resource "oci_core_instance" "atlas" {
  # availability_domain = data.oci_identity_availability_domains.borealis.availability_domains[0].name
  availability_domain = "kMzJ:US-CHICAGO-1-AD-1"
  compartment_id      = oci_identity_compartment.borealis.id
  shape               = "VM.Standard.A1.Flex"

  create_vnic_details {
    assign_public_ip = "true"
    subnet_id        = oci_core_subnet.borealis_global.id
  }

  display_name = "atlas"

  shape_config {
    memory_in_gbs = "24"
    nvmes         = "0"
    ocpus         = "4"
    vcpus         = "4"
  }
}
