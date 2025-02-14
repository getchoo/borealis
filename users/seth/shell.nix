{ config, ... }:

{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = config.home.sessionVariables.EDITOR;
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
