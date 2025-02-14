{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    inputs.self.nixosModules.default
  ];

  borealis = {
    profiles.personal.enable = true;

    determinate.enable = true;

    remote-builders = {
      enable = true;

      builders = {
        atlas = true;
        macstadium = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    wslu
  ];

  networking.hostName = "glados-wsl";

  nix.package = pkgs.nixVersions.latest;

  nixpkgs.hostPlatform = "x86_64-linux";

  # Something, something `resolv.conf` error
  # (nixos-wsl probably doesn't set it)
  security.apparmor.enable = false;

  services = {
    resolved.enable = false;
  };

  system.stateVersion = "23.11";

  wsl = {
    enable = true;
    defaultUser = "seth";
    interop = {
      includePath = false; # this is so annoying
      register = true;
    };
  };
}
