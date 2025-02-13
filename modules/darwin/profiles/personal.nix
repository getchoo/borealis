{ config, lib, ... }:
let
  cfg = config.profiles.personal;
in
{
  options.profiles.personal = {
    enable = lib.mkEnableOption "the Personal profile";
  };

  config = lib.mkIf cfg.enable {
    desktop.enable = true;

    traits = {
      users = {
        seth.enable = true;
      };
    };
  };
}
