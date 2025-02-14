{
  config,
  pkgs,
  ...
}:

{
  programs.zsh = {
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";

    history = {
      expireDuplicatesFirst = true;
      path = "${config.xdg.stateHome}/zsh/zsh_history";
      save = 1000;
      size = 100;
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "nix-zsh-completions";
        src = pkgs.nix-zsh-completions;
        file = "share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh";
      }

      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }

      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }

      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.plugin.zsh";
      }
    ];

    completionInit = ''
      autoload -Uz bashcompinit compinit
      local zdump="${config.xdg.cacheHome}/zsh/zdump"
      bashcompinit
      compinit -d "$zdump"
      if [[ ! "$zdump.zwc" -nt "$zdump" ]]
      then
      	zcompile "$zdump"
      fi
      unset zdump
    '';

    initExtra = ''
      if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-*.zsh" ]]; then
        source "$XDG_CACHE_HOME/p10k-instant-prompt-*.zsh"
      fi
      autoload -Uz promptinit colors
      promptinit
      colors

      zmodload zsh/zutil
      zmodload zsh/complist
      zstyle ":completion::*" group-name ""
      zstyle ":completion:*" menu "select"
      zstyle ":completion:*" squeeze-slashes "true"
      zstyle ":completion::*" use-cache "true"
      zstyle ":completion::*" cache-path "$zdump"

      unsetopt beep
      unsetopt hist_beep
      unsetopt ignore_braces
      unsetopt list_beep
      setopt always_to_end
      setopt prompt_subst
      setopt share_history

      # clear backbuffer with ctrl-l
      function clear-screen-and-scrollback() {
      		echoti civis >"$TTY"
      		printf '%b' '\e[H\e[2J' >"$TTY"
      		zle .reset-prompt
      		zle -R
      		printf '%b' '\e[3J' >"$TTY"
      		echoti cnorm >"$TTY"
      }

      zle -N clear-screen-and-scrollback
      bindkey '^L' clear-screen-and-scrollback

      [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
    '';
  };
}
