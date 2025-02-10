{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.boot.lanzaboote;
in

{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  config = lib.mkMerge [
    {
      boot.lanzaboote = {
        pkiBundle = "/etc/secureboot";

        settings = {
          console-mode = "auto";
          editor = false;
          timeout = 0;
        };
      };
    }

    (lib.mkIf cfg.enable {
      boot = {
        initrd.systemd.enable = true; # For unlocking LUKS root with TPM2
        loader.systemd-boot.enable = lib.mkForce false; # Lanzaboote replaces this
      };

      environment.systemPackages = [
        # manual Lanzaboote maintenance (NOTE: I have not actually used this since ~2022)
        pkgs.sbctl
        # TODO: Is this actually required for using `tpm2-device=auto` to unlock LUKS volumes in initrd? Probably
        pkgs.tpm2-tss
      ];
    })
  ];
}
