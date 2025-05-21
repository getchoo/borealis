{ lib, ... }:

let
  strictDmarc = {
    _dmarc = {
      type = "TXT";
      content = "'v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;'";
    };

    domainkey = {
      name = "*._domainkey";
      type = "TXT";
      content = "'v=DKIM1; p='";
    };

    spf = {
      name = "@";
      type = "TXT";
      content = "'v=spf1 -all'";
    };
  };

  atlasIp = lib.tfRef "resource.oci_core_instance.atlas.public_ip";
  atlasSubdomains = [
    "auth"
    "git"
    "hedgedoc"
    "miniflux"
    "music"
  ];

  pagesSubdomainFor = project: lib.tfRef "resource.cloudflare_pages_project.${project}.subdomain";
in

{
  borealis.dns = {
    "getchoo.com" = {
      zoneId = lib.tfRef "var.cloudflare_getchoo_com_zone_id";

      records = lib.mkMerge [
        strictDmarc

        {
          root = {
            name = "@";
            type = "CNAME";
            content = pagesSubdomainFor "getchoo_website";
          };

          www = {
            type = "CNAME";
            content = "getchoo.com";
          };

          api = {
            type = "CNAME";
            content = pagesSubdomainFor "teawie_api";
          };

          keyoxide = {
            name = "@";
            content = "'$argon2id$v=19$m=512,t=256,p=1$AlA6W5fP7J14zMsw0W5KFQ$EQz/NCE0/TQpE64r2Eo/yOpjtMZ9WXevHsv3YYP7CXg'";
            type = "TXT";
          };
        }

        (lib.genAttrs atlasSubdomains (
          lib.const {
            type = "A";
            content = atlasIp;
          }
        ))

        {
          # Content is streamed from here
          "music" = {
            proxied = false;
          };
        }
      ];
    };
  };
}
