{ inputs, ... }:

{
  imports = [
    # NixOS-specific imports for ../shared/mixins
    inputs.home-manager.nixosModules.home-manager
    inputs.lix-module.nixosModules.default

    ./acme.nix
    ./agenix.nix
    ./budgie.nix
    ./fonts.nix
    ./gnome.nix
    ./lanzaboote.nix
    ./nginx.nix
    ./niri.nix
    ./nix.nix
    ./nvidia.nix
    ./plasma.nix
    ./resolved.nix
    ./security.nix
    ./tailscale.nix
    ./users.nix
    ./wsl.nix
    ./xserver.nix
    ./zram.nix
  ];
}
