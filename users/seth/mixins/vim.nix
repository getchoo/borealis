{
  config,
  pkgs,
  ...
}:

let
  inherit (config.xdg) configHome dataHome stateHome;
in

{
  programs.vim = {
    packageConfigurable = pkgs.vim;

    settings = {
      expandtab = false;
      shiftwidth = 2;
      tabstop = 2;
    };

    extraConfig = ''
      " https://wiki.archlinux.org/title/XDG_Base_Directory
      set runtimepath^=${configHome}/vim
      set runtimepath+=${dataHome}/vim
      set runtimepath+=${configHome}/vim/after

      set packpath^=${dataHome}/vim,${configHome}/vim
      set packpath+=${configHome}/vim/after,${dataHome}/vim/after
      set packpath^=${dataHome}/vim,${configHome}/vim
      set packpath+=${configHome}/vim/after,${dataHome}/vim/after

      let g:netrw_home = "${dataHome}/vim"
      call mkdir("${dataHome}/vim/spell", 'p')

      set backupdir=${stateHome}/vim/backup | call mkdir(&backupdir, 'p')
      set directory=${stateHome}/vim/swap   | call mkdir(&directory, 'p')
      set undodir=${stateHome}/vim/undo     | call mkdir(&undodir,   'p')
      set viewdir=${stateHome}/vim/view     | call mkdir(&viewdir,   'p')
      set viminfofile=${stateHome}/vim/viminfo
    '';
  };
}
