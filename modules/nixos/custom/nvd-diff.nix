{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.borealis.nvd-diff;
in

{
  options.borealis.nvd-diff = {
    enable = lib.mkEnableOption "`nvd` to show configuration diffs on upgrade";
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts."upgrade-diff" = {
      supportsDryActivation = true;

      text = ''
        ${lib.getExe pkgs.nvd} \
          --nix-bin-dir=${config.nix.package}/bin \
          diff /run/current-system "$systemConfig"
      '';
    };
  };
}
