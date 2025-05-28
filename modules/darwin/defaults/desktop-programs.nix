{ config, lib, ... }:

{
  config = lib.mkIf config.homebrew.enable {
    homebrew.casks = [
      "brave-browser"
      "iterm2"
    ];
  };
}
