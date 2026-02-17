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
      PAGER = lib.getExe pkgs.moor;
      VISUAL = config.home.sessionVariables.EDITOR;

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
