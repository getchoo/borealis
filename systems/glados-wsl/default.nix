{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.default
  ];

  borealis = {
    profiles.desktop.enable = true;

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
    tailscale.enable = false;
  };

  system.stateVersion = "23.11";

  virtualisation = {
    containers.enable = true;
    podman.enable = true;
  };

  wsl = {
    enable = true;
    defaultUser = "seth";
  };
}
