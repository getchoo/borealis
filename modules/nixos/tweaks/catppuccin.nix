{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.tweaks.catppuccin;
in
{
  options.tweaks.catppuccin = {
    enable = lib.mkEnableOption "Catppuccin themeing";
  };

  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      accent = "mauve";
      flavor = "mocha";

      # Don't use modules with IFD by default
      tty.enable = false;
    };
  };
}
