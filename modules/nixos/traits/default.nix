{
  imports = [
    ./acme.nix
    ./auto-upgrade.nix
    ./cloudflared.nix
    ./containers.nix
    ./hercules.nix
    ./locale.nix
    ./nginx.nix
    ./nvk
    ./promtail.nix
    ./secrets.nix
    ./tailscale.nix
    ./user-setup.nix
    ./users.nix
  ];
}
