locals {
  zone_ids = [var.cloudflare_getchoo_com_zone_id]

  dmarc_hardening_records = [
    {
      name    = "_dmarc"
      type    = "TXT"
      content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;"
    },
    {
      name    = "*._domainkey"
      type    = "TXT"
      content = "v=DKIM1; p="
    },
    {
      name    = "@"
      type    = "TXT"
      content = "v=spf1 -all"
    }
  ]

  dmarc_records = flatten([for zone_id in local.zone_ids : [
    for record in local.dmarc_hardening_records : {
      zone_id = zone_id
      name    = record.name
      type    = record.type
      content = record.content
    }
  ]])

  getchoo_tunnels = data.cloudflare_zero_trust_tunnel_cloudflared.getchoo_tunnels
  getchoo_records = [
    {
      name    = "@"
      type    = "CNAME"
      content = resource.cloudflare_pages_project.getchoo_website.subdomain
    },
    {
      name    = "www"
      type    = "CNAME"
      content = "getchoo.com"
    },
    {
      name    = "api"
      type    = "CNAME"
      content = resource.cloudflare_pages_project.teawie_api.subdomain
    },
    {
      name    = "miniflux"
      type    = "CNAME"
      content = "${local.getchoo_tunnels["atlas-nginx"].id}.cfargotunnel.com"
    },
    {
      name    = "git"
      type    = "CNAME"
      content = "${local.getchoo_tunnels["atlas-nginx"].id}.cfargotunnel.com"
    },
    {
      name    = "@"
      content = "$argon2id$v=19$m=512,t=256,p=1$AlA6W5fP7J14zMsw0W5KFQ$EQz/NCE0/TQpE64r2Eo/yOpjtMZ9WXevHsv3YYP7CXg"
      type    = "TXT"
    }
  ]
}

data "cloudflare_zero_trust_tunnel_cloudflared" "getchoo_tunnels" {
  for_each = toset(["atlas-nginx"])

  account_id = var.cloudflare_account_id
  name       = each.key
}

resource "cloudflare_record" "getchoo_com" {
  for_each = { for record in local.getchoo_records : "${record.name}-${record.type}" => record }

  zone_id = var.cloudflare_getchoo_com_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
}

resource "cloudflare_record" "dmarc_hardening" {
  for_each = { for record in local.dmarc_records : "${record.zone_id}-${record.name}" => record }

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
}

resource "cloudflare_authenticated_origin_pulls" "origins" {
  for_each = toset([var.cloudflare_getchoo_com_zone_id])

  zone_id = each.key
  enabled = true
}

resource "cloudflare_zone_dnssec" "zones" {
  for_each = toset([var.cloudflare_getchoo_com_zone_id])

  zone_id = each.key
}

resource "cloudflare_zone_settings_override" "strict_ssl" {
  for_each = toset([var.cloudflare_getchoo_com_zone_id])

  zone_id = each.key

  settings {
    always_use_https = "on"
    ssl              = "strict"
  }
}
