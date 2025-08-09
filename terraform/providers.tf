variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

provider "cloudflare" {
  api_token = data.hcp_vault_secrets_app.borealis.secrets.cloudflare_api_token
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

provider "oci" {
  fingerprint = var.oracle_fingerprint
  # NOTE: Base64-encoded to avoid newlines, etc.
  # https://github.com/oracle/terraform-provider-oci/issues/2198
  private_key  = base64decode(data.hcp_vault_secrets_app.borealis.secrets.oracle_private_key)
  region       = var.oracle_region
  tenancy_ocid = var.oracle_tenancy_ocid
  user_ocid    = var.oracle_user_ocid
}

variable "hcp_client_id" {
  type = string
}

variable "hcp_client_secret" {
  type = string
}

variable "vault_app" {
  type    = string
  default = "borealis"
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

data "hcp_vault_secrets_app" "borealis" {
  app_name = var.vault_app
}

variable "tailscale_tailnet" {
  type = string
}

provider "tailscale" {
  oauth_client_id     = data.hcp_vault_secrets_app.borealis.secrets.tailscale_oauth_client_id
  oauth_client_secret = data.hcp_vault_secrets_app.borealis.secrets.tailscale_oauth_client_secret
  tailnet             = var.tailscale_tailnet
}
