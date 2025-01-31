resource "cloudflare_pages_project" "getchoo_website" {
  account_id        = var.cloudflare_account_id
  name              = "getchoo-website"
  production_branch = "main"

  build_config {
    build_caching   = true
    build_command   = "./build-site.sh"
    destination_dir = "/dist"
  }

  source {
    type = "github"
    config {
      owner             = "getchoo"
      repo_name         = "website"
      production_branch = "main"
    }
  }
}

resource "cloudflare_pages_domain" "getchoo_website" {
  account_id   = var.cloudflare_account_id
  domain       = "getchoo.com"
  project_name = "getchoo-website"
}

resource "cloudflare_pages_project" "teawie_api" {
  account_id        = var.cloudflare_account_id
  name              = "teawie-api"
  production_branch = "main"

  build_config {
    build_caching   = true
    build_command   = "pnpm run lint && pnpm run build"
    destination_dir = "/dist"
  }

  source {
    type = "github"
    config {
      owner             = "getchoo"
      repo_name         = "teawieAPI"
      production_branch = "main"
    }
  }
}

resource "cloudflare_pages_domain" "teawie_api" {
  account_id   = var.cloudflare_account_id
  domain       = "api.getchoo.com"
  project_name = "teawie-api"
}
