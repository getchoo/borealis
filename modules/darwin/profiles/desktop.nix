{ config, lib, ... }:

let
  cfg = config.borealis.profiles.desktop;
in

{
  options.borealis.profiles.desktop = {
    enable = lib.mkEnableOption "the desktop profile";
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [
        "ghostty"
        "orion"
      ];
    };
  };
}
