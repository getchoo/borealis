terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "getchoo"

    workspaces {
      name = "borealis"
    }
  }

  required_providers {
    cloudflare = {
      source  = "registry.opentofu.org/cloudflare/cloudflare"
      version = "~> 4"
    }
    oci = {
      source  = "registry.opentofu.org/oracle/oci"
      version = "~> 6"
    }
    hcp = {
      source  = "registry.opentofu.org/hashicorp/hcp"
      version = "~> 0.102"
    }
    tailscale = {
      source  = "registry.opentofu.org/tailscale/tailscale"
      version = "~> 0.17"
    }
  }
}
