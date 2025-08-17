{ config, lib, ... }:

let
  cfg = config.borealis.profiles.desktop;
in

{
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
