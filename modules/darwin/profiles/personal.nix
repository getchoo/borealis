{ config, lib, ... }:

let
  cfg = config.borealis.profiles.personal;
in

{
  options.borealis.profiles.personal = {
    enable = lib.mkEnableOption "the Personal profile";
  };

  config = lib.mkIf cfg.enable {
    borealis = {
      users = {
        seth.enable = true;
      };
    };

    determinate.enable = true;

    homebrew.enable = true;
  };
}
