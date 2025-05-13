{ lib, ... }:

let
  vaultSecret = name: lib.tfRef "data.hcp_vault_secrets_app.borealis.secrets.${name}";
in

{
  provider = {
    cloudflare = {
      api_token = vaultSecret "cloudflare_api_token";
    };

    oci = {
      fingerprint = lib.tfRef "var.oracle_fingerprint";
      # NOTE: Base64-encoded to avoid newlines, etc.
      # https://github.com/oracle/terraform-provider-oci/issues/2198
      private_key = "\${base64decode(data.hcp_vault_secrets_app.borealis.secrets.oracle_private_key)}";
      region = lib.tfRef "var.oracle_region";
      tenancy_ocid = lib.tfRef "var.oracle_tenancy_ocid";
      user_ocid = lib.tfRef "var.oracle_user_ocid";
    };

    hcp = {
      client_id = lib.tfRef "var.hcp_client_id";
      client_secret = lib.tfRef "var.hcp_client_secret";
    };

    tailscale = {
      oauth_client_id = vaultSecret "tailscale_oauth_client_id";
      oauth_client_secret = vaultSecret "tailscale_oauth_client_secret";
      tailnet = lib.tfRef "var.tailscale_tailnet";
    };
  };
}
