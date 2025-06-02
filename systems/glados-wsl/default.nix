{
  lib,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.self.nixosModules.default

    inputs.determinate.nixosModules.default
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

  lix.enable = lib.mkForce false;

  networking.hostName = "glados-wsl";

  nix.package = lib.mkForce pkgs.nix;

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    overlays = [
      (_: prev: { nix = inputs.self.legacyPackages.${prev.stdenv.hostPlatform.system}.dix; })
    ];
  };

  services = {
    tailscale.enable = false;
  };

  system.stateVersion = "23.11";

  wsl = {
    enable = true;
    defaultUser = "seth";
  };
}
