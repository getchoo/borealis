{ config, inputs, ... }:
{
  imports = [
    inputs.self.darwinModules.default
  ];

  borealis = {
    profiles.personal.enable = true;
  };

  homebrew.casks = [
    "altserver"
    "discord"
    "spotify"
    "prismlauncher"
  ];

  networking = {
    computerName = config.networking.hostName;
    hostName = "caroline";
  };

  nix.settings.trusted-users = [ "seth" ];
  nixpkgs.hostPlatform = "x86_64-darwin";

  services.tailscale.enable = true;

  system = {
    primaryUser = "seth";
    stateVersion = 4;
  };
}
