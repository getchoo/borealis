{
  config,
  lib,
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
          register = true;
        };
      };
    }

    (lib.mkIf config.wsl.enable {
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
