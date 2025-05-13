{ lib, ... }:

let
  vars = [
    "cloudflare_account_id"
    "cloudflare_getchoo_com_zone_id"

    "oracle_fingerprint"
    "oracle_region"
    "oracle_tenancy_ocid"
    "oracle_user_ocid"

    "hcp_client_id"
    "hcp_client_secret"
    "vault_app"

    "tailscale_tailnet"
  ];
in

{
  data = {
    hcp_vault_secrets_app = {
      borealis = {
        app_name = lib.tfRef "var.vault_app";
      };
    };
  };

  variable = lib.genAttrs vars (
    lib.const {
      type = "string";
    }
  );
}
