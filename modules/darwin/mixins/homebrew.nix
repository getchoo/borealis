{ lib, ... }:

{
  config = {
    homebrew = {
      onActivation = lib.mkDefault {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };

      caskArgs = {
        no_quarantine = true;
        require_sha = false;
      };
    };
  };
}
