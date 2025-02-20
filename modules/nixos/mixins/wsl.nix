{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];

  config = lib.mkMerge [
    {
      wsl = {
        interop = {
          includePath = false; # this is so annoying
          register = true;
        };
      };
    }

    (lib.mkIf config.wsl.enable {
      environment.systemPackages = [
        pkgs.wslu
      ];

      security = {
        # Something, something `resolv.conf` error
        # (nixos-wsl probably doesn't set it)
        apparmor.enable = false;
        # `run0` fails with `Failed to start transient service unit: Interactive authentication required.`
        sudo.enable = true;
      };

      services = {
        resolved.enable = false;
      };
    })
  ];
}
