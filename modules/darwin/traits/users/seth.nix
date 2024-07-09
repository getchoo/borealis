{ config, lib, ... }:
let
  cfg = config.traits.users.seth;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home-manager.users.seth = {
        # NOTE: this module is for linux, not mac
        seth.desktop.enable = false;
      };
    })
  ];
}
