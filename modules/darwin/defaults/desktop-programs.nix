{ config, lib, ... }:

{
  config = lib.mkIf config.homebrew.enable {
    homebrew.casks = [
      "ghostty"
      "orion"
    ];
  };
}
