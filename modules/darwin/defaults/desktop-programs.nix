{ config, lib, ... }:

{
  config = lib.mkIf config.homebrew.enable {
    homebrew.casks = [
      "iterm2"
      "orion"
    ];
  };
}
