{
  config,
  lib,
  pkgs,
  unstable,
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
        ${lib.getExe pkgs.dix or unstable.dix} /run/current-system "$systemConfig"
      '';
    };
  };
}
