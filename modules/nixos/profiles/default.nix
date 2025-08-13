{ lib, ... }:

{
  imports = [
    ./desktop.nix
    ./personal.nix
    ./server.nix
  ];

  ## Common options

  borealis = {
    nvd-diff.enable = true;
  };

  documentation.nixos.enable = lib.mkDefault false;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  programs = {
    git.enable = lib.mkDefault true;

    vim = {
      enable = lib.mkDefault true;
      defaultEditor = lib.mkDefault true;
    };
  };

  system = {
    # Broken when configuration is from Flake
    tools.nixos-option.enable = lib.mkDefault false;
  };
}
