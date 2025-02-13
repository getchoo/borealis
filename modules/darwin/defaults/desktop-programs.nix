{ config, lib, ... }:

{
  config = lib.mkIf config.homebrew.enable {
    homebrew.casks = [
      "chromium"
      "iterm2"
    ];
  };
}
