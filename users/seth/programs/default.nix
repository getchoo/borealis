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
    ./gh.nix
    ./ghostty.nix
    ./git.nix
    ./gpg.nix
    ./mangohud.nix
    ./neovim.nix
    ./nu.nix
    ./ssh.nix
    ./vim.nix
    ./vscode.nix
    ./zsh.nix
  ];

  config = lib.mkIf config.seth.enable {
    home.packages = with pkgs; [
      hydra-check
      nixfmt-rfc-style
      (nurl.override { nix = config.nix.package; })
    ];

    programs = {
      bat.enable = lib.mkDefault true;
      btop.enable = lib.mkDefault true;

      direnv = {
        enable = lib.mkDefault true;
        nix-direnv = {
          enable = true;
          package = pkgs.nix-direnv.override { nix = config.nix.package; };
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
