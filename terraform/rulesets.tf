resource "cloudflare_ruleset" "getchoo_com_redirects" {
  kind  = "zone"
  name  = "funny redirects"
  phase = "http_request_dynamic_redirect"

  description = "Redirect to Tick Tock by Joji"
  rules {
    expression = "(http.request.uri.path eq \"/hacks\" and http.host eq \"getchoo.com\")"

    action = "redirect"
    action_parameters {
      from_value {
        preserve_query_string = false
        status_code           = 301
        target_url {
          value = "https://www.youtube.com/watch?v=RvVdFXOFcjw"
        }
      }
    }
    description = "tick tock hacks"
    enabled     = true
  }

  zone_id = var.cloudflare_getchoo_com_zone_id
}

