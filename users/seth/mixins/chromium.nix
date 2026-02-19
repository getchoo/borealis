{ pkgs, ... }:

{
  programs.chromium = {
    dictionaries = [ pkgs.hunspellDictsChromium.en_US ];

    extensions = [
      # 1Password
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; }
      # uBlock Origin Lite
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; }
      # Floccus Bookmark Sync
      { id = "fnaicdffflnofjppbagibeoednhnbjhg"; }
      # Tabby Cat
      { id = "mefhakmgclhhfbdadeojlkbllmecialg"; }
      # Startpage
      { id = "fgmjlmbojbkmdpofahffgcpkhkngfpef"; }
    ];
  };
}
