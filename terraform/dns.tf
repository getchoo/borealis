locals {
  records = [
    # DMARC
    {
      resource_name = "_dmarc_txt"
      name          = "_dmarc"
      type          = "TXT"
      content       = "'v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;'"
    },
    {
      resource_name = "dmarc_domainkey"
      name          = "*._domainkey"
      type          = "TXT"
      content       = "'v=DKIM1; p='"
    },
    {
      resource_name = "dmarc_spf"
      name          = "@"
      type          = "TXT"
      content       = "'v=spf1 -all'"
    },

    # Regular content
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
      name    = "auth"
      type    = "A"
      content = resource.oci_core_instance.atlas.public_ip
    },
    {
      name    = "miniflux"
      type    = "A"
      content = resource.oci_core_instance.atlas.public_ip
    },
    {
      name    = "git"
      type    = "A"
      content = resource.oci_core_instance.atlas.public_ip
    },
    {
      name    = "hedgedoc"
      type    = "A"
      content = resource.oci_core_instance.atlas.public_ip
    },
    {
      name    = "rime"
      type    = "A"
      content = resource.oci_core_instance.atlas.public_ip
    },
    {
      name    = "static"
      type    = "A"
      content = resource.oci_core_instance.atlas.public_ip
    },

    # Keyoxide proof
    {
      resource_name = "keyoxide_proof"
      name          = "@"
      content       = "'$argon2id$v=19$m=512,t=256,p=1$AlA6W5fP7J14zMsw0W5KFQ$EQz/NCE0/TQpE64r2Eo/yOpjtMZ9WXevHsv3YYP7CXg'"
      type          = "TXT"
    }
  ]
}

resource "cloudflare_record" "getchoo_com" {
  for_each = { for record in local.records : lookup(record, "resource_name", "${record.name}-${record.type}") => record }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content

  proxied = lookup(each.value, "proxied", each.value.type != "TXT")
}

resource "cloudflare_authenticated_origin_pulls" "origin" {
  zone_id = var.cloudflare_zone_id
  enabled = true
}

resource "cloudflare_zone_dnssec" "zone" {
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_zone_settings_override" "strict_ssl" {
  zone_id = var.cloudflare_zone_id

  settings {
    always_use_https = "on"
    ssl              = "strict"
  }
}
