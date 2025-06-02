{
  lib,
  inputs,
  inputs',
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

  nix.package = lib.mkForce (
    inputs'.dix.packages.default.overrideScope (
      _: prev: {
        nix-flake = prev.nix-flake.overrideAttrs (old: {
          patches = old.patches or [ ] ++ [ ./allow-registry-lookups-for-overridden-inputs.patch ];
          patchFlags = old.patchFlags or [ ] ++ [ "-p3" ];
        });
      }
    )
  );

  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    tailscale.enable = false;
  };

  system.stateVersion = "23.11";

  wsl = {
    enable = true;
    defaultUser = "seth";
  };
}
