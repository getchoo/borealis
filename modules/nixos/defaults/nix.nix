{ lib, inputs, ... }:
{
  nix = {
    channel.enable = lib.mkDefault false;
    settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };

  nixpkgs.config.allowAliases = false;

  # Link inputs for use in `$NIX_PATH`
  systemd.tmpfiles.settings = {
    nix-inputs = lib.mapAttrs' (
      name: input:
      lib.nameValuePair "/etc/nix/inputs/${name}" {
        L = {
          argument = input.outPath;
        };
      }
    ) inputs;
  };
}
