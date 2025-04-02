{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.default
    inputs.lix-module.nixosModules.default
  ];

  borealis = {
    profiles.personal.enable = true;

    remote-builders = {
      enable = true;

      builders = {
        atlas = true;
        macstadium = true;
      };
    };
  };

  networking.hostName = "glados-wsl";

  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    guix = {
      enable = true;
      gc.enable = true;
    };

    tailscale.enable = false;
  };

  system.stateVersion = "23.11";

  wsl = {
    enable = true;
    defaultUser = "seth";
  };
}
