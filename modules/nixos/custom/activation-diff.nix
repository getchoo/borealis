{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.borealis.activation-diff;
in

{
  options.borealis.activation-diff = {
    enable = lib.mkEnableOption "configuration diffs on activation";
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.activation-diff = {
      supportsDryActivation = true;

      text = ''
        ${lib.getExe pkgs.dix} diff /run/current-system "$systemConfig"
      '';
    };
  };
}
