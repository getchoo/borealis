{ config, lib, ... }:

let
  cfg = config.seth.programs.ghostty;
in

{
  options.seth.programs.ghostty = {
    enable = lib.mkEnableOption "Ghostty configuration" // {
      default = config.seth.desktop.enable;
      defaultText = lib.literalExample "config.seth.desktop.enable";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;

      enableBashIntegration = true;
      enableFishIntegration = true;

      settings = {
        bold-is-bright = true;
      };
    };
  };
}
