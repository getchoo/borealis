{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index

    ./bash.nix
    ./chromium.nix
    ./firefox
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./mangohud.nix
    ./moar.nix
    ./ncspot.nix
    ./neovim.nix
    ./nu.nix
    ./ssh.nix
    ./starship
    ./vim.nix
    ./vscode.nix
    ./yazi.nix
    ./zellij.nix
    ./zsh.nix
  ];

  config = lib.mkIf config.seth.enable {
    programs = {
      bat.enable = lib.mkDefault true;
      btop.enable = lib.mkDefault true;

      direnv = {
        enable = lib.mkDefault true;
        nix-direnv = {
          enable = true;
          package = lib.mkDefault (pkgs.nix-direnv.override { nix = pkgs.lix; });
        };
      };

      eza = {
        enable = lib.mkDefault true;
        icons = "auto";
      };

      fd.enable = lib.mkDefault true;
      ripgrep.enable = lib.mkDefault true;
      nix-index-database.comma.enable = true;
    };

    xdg.enable = true;
  };
}
