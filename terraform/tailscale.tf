locals {
  personal_devices = [
    "caroline",
    "glados",
    "glados-windows",
    "iphone-14"
  ]

  server_devices = [
    "atlas"
  ]

  devices = concat(local.personal_devices, local.server_devices)
}

data "tailscale_device" "devices" {
  for_each = toset(local.devices)

  name     = "${each.key}.tailc59d6.ts.net"
  wait_for = "60s"
}

resource "tailscale_device_tags" "personal" {
  for_each = toset(local.personal_devices)

  device_id = data.tailscale_device.devices[each.key].id
  tags      = ["tag:personal"]
}

resource "tailscale_device_tags" "server" {
  for_each = toset(local.server_devices)

  device_id = data.tailscale_device.devices[each.key].id
  tags      = ["tag:server"]
}

resource "tailscale_dns_preferences" "preferences" {
  magic_dns = true
}

resource "tailscale_acl" "acl" {
  acl = jsonencode({
    acls = [
      {
        action = "accept"
        dst    = ["*:*"]
        src    = ["tag:personal"]
      },
      {
        action = "accept"
        dst    = ["tag:server:*"]
        src    = ["tag:server"]
      }
    ]

    ssh = [
      {
        action = "accept"
        dst    = ["tag:server", "tag:personal"]
        src    = ["tag:personal"]
        users  = ["autogroup:nonroot", "root"]
      }
    ]

    tagOwners = {
      "tag:personal" = ["getchoo@github"]
      "tag:server"   = ["getchoo@github"]
    }
  })
}
