{ lib, ... }:

{
  imports = [
    ./desktop-programs.nix
    ./fonts.nix
    ./nix.nix
    ./programs.nix
    ./security.nix
    ./users.nix
  ];

  documentation.nixos.enable = lib.mkDefault false;
}
