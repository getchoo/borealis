{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.seth.programs.chromium;
in
{
  options.seth.programs.chromium = {
    enable = lib.mkEnableOption "Chromium configuration" // {
      default = config.seth.desktop.enable;
      defaultText = lib.literalExpression "config.seth.desktop.enable";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;

      dictionaries = [ pkgs.hunspellDictsChromium.en_US ];

      extensions = [
        # uBlock Origin
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
        # Bitwarden
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
        # Floccus Bookmark Sync
        { id = "fnaicdffflnofjppbagibeoednhnbjhg"; }
        # Tabby Cat
        { id = "mefhakmgclhhfbdadeojlkbllmecialg"; }
        # Startpage
        { id = "fgmjlmbojbkmdpofahffgcpkhkngfpef"; }
      ];
    };
  };
}
