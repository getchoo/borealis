{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.borealis.cloudflare-dynamic-dns;

  settingsFormat = pkgs.formats.yaml { };
  settingsSubmodule = {
    freeformType = settingsFormat.type;

    options = {
      iface = lib.mkOption {
        type = lib.types.str;
        description = "Network interface name to look up for an address.";
        example = "eth0";
      };

      ipcmd = lib.mkOption {
        type = lib.types.str;
        description = ''
          Shell command to run to get the address.

          NOTE: Should return one address per line.
        '';
      };

      domains = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "One of more domain to assign the address to.";
        example = [
          "example.com"
          "*.example.com"
        ];
      };

      tokenFile = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path ot a file containing the Cloudflare API token
          with edit access rights to the DNS zone.
        '';
      };
    };
  };
in

{
  options.borealis.cloudflare-dynamic-dns = {
    enable = lib.mkEnableOption "cloudflare-dynamic-dns";

    package = lib.mkPackageOption pkgs "cloudflare-dynamic-dns" { };

    settings = lib.mkOption {
      type = lib.types.submodule settingsSubmodule;
      default = { };
      description = ''
        Settings for `cloudflare-dynamic-dns`.

        See https://github.com/Zebradil/cloudflare-dynamic-dns?tab=readme-ov-file#usage for more.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd = {
      packages = [ cfg.package ];
    };
  };
}
