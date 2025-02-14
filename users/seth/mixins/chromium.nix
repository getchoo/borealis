{ pkgs, ... }:

{
  programs.chromium = {
    dictionaries = [ pkgs.hunspellDictsChromium.en_US ];

    extensions = [
      # uBlock Origin Lite
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; }
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
}
