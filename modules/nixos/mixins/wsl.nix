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

      programs.ssh.package =
        pkgs.runCommand "openssh-wsl"
          {
            env = {
              toLink = toString [
                "ssh.exe"
                "ssh-add.exe"
              ];
              system32 = "/mnt/c/Windows/System32/OpenSSH";
            };
          }
          ''
            mkdir -p $out/bin
            for sshBin in $toLink; do
              ln -s $system32/$sshBin $out/bin/''${sshBin/%.exe/}
            done
          '';

      services = {
        resolved.enable = false;
      };
    })
  ];
}
