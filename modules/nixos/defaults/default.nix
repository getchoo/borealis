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

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };
}
