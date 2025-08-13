{ lib, ... }:

{
  nix = {
    channel.enable = lib.mkDefault false;

    settings.trusted-users = [
      "@wheel"
    ];
  };

  nixpkgs.config.allowAliases = false;
}
