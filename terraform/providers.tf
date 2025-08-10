variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "oracle_fingerprint" {
  type = string
}

variable "oracle_region" {
  type = string
}

variable "oracle_tenancy_ocid" {
  type = string
}

variable "oracle_user_ocid" {
  type = string
}

variable "oracle_private_key" {
  type      = string
  sensitive = true
}

provider "oci" {
  fingerprint = var.oracle_fingerprint
  # NOTE: Base64-encoded to avoid newlines, etc.
  # https://github.com/oracle/terraform-provider-oci/issues/2198
  private_key  = base64decode(var.oracle_private_key)
  region       = var.oracle_region
  tenancy_ocid = var.oracle_tenancy_ocid
  user_ocid    = var.oracle_user_ocid
}

variable "tailscale_tailnet" {
  type = string
}

variable "tailscale_oauth_client_id" {
  type      = string
  sensitive = true
}

variable "tailscale_oauth_client_secret" {
  type      = string
  sensitive = true
}

provider "tailscale" {
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
  tailnet             = var.tailscale_tailnet
}
