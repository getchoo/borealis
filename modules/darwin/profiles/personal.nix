{ config, lib, ... }:

let
  cfg = config.profiles.personal;
in

{
  options.profiles.personal = {
    enable = lib.mkEnableOption "the Personal profile";
  };

  config = lib.mkIf cfg.enable {
    borealis = {
      users = {
        seth.enable = true;
      };
    };

    homebrew.enable = true;
  };
}
