{ config, lib, ... }:

let
  cfg = config.determinate;
in

{
  options.determinate = {
    enable = lib.mkEnableOption "Determinate Nix";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.nix.enable;
        message = "`nix.enable` must be `false`. Determinate Nix will manage itself.";
      }
    ];

    nix.enable = false;
  };
}
