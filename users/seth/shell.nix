{
  config,
  lib,
  pkgs,
  ...
}:

{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = config.home.sessionVariables.EDITOR;

      PAGER = lib.getExe pkgs.moor;
      MOOR = "-quit-if-one-screen -terminal-fg";

      # Force XDG spec on some apps
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    };

    shellAliases = {
      diff = "diff --color=auto";
      g = "git";
      gs = "g status";
    };
  };
}
