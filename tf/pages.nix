{ lib, ... }:

let
  account_id = lib.tfRef "var.cloudflare_account_id";
in

{
  borealis.cloudflare.pages = {
    domains = {
      getchoo_website = {
        inherit account_id;
        domain = "getchoo.com";
        project_name = "getchoo-website";
      };

      teawie_api = {
        inherit account_id;
        domain = "api.getchoo.com";
        project_name = "teawie-api";
      };
    };

    projects = {
      getchoo_website = {
        inherit account_id;
        name = "getchoo-website";
        production_branch = "main";

        build_config = {
          build_caching = true;
          build_command = "./build.sh";
          destination_dir = "/dist";
        };

        source = {
          type = "github";
          config = {
            owner = "getchoo";
            repo_name = "website";
            production_branch = "main";
          };
        };
      };

      teawie_api = {
        inherit account_id;

        name = "teawie-api";
        production_branch = "main";

        build_config = {
          build_caching = true;
          build_command = "pnpm run lint && pnpm run build";
          destination_dir = "/dist";
        };

        source = {
          type = "github";
          config = {
            owner = "getchoo";
            repo_name = "teawieAPI";
            production_branch = "main";
          };
        };
      };
    };
  };
}
