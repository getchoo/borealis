{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  config = {
    catppuccin.enable = true;

    home.packages = [
      pkgs.getchvim

      pkgs.hydra-check
      pkgs.nixfmt
    ];

    programs = {
      bat.enable = true;
      bash.enable = true;
      btop.enable = true;

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      eza = {
        enable = true;
        icons = "auto";
      };

      fd.enable = true;
      fish.enable = true;
      git.enable = true;
      gpg.enable = true;
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
      ripgrep.enable = true;
      ssh.enable = true;
      vim.enable = true;
    };

    xdg.enable = true;
  };
}
