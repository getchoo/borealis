{ pkgs, ... }:

{
  # NOTE: Not using the actual `programs.vim` module to avoid an annoying warning
  environment.systemPackages = [ pkgs.vim ];

  programs = {
    bash.enable = true;
    zsh.enable = true;
  };
}
