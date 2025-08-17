{
  config,
  pkgs,
  inputs,
  inputs',
  ...
}:

let
  overrideNix = pkg: pkg.override { nix = config.nix.package; };
in

{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  config = {
    catppuccin.enable = true;

    home.packages = [
      (inputs'.getchvim.packages.default.override {
        nixd = inputs'.nixd.packages.nixd.override (prev: {
          # Use user's nix if possible
          nixComponents = config.nix.package.libs or prev.nixComponents;
        });
      })

      pkgs.hydra-check
      pkgs.nixfmt

      # TODO: `programs.nix-index-database.comma.package` should probably exist
      (inputs'.nix-index-database.packages.comma-with-db.override (prev: {
        comma = overrideNix prev.comma;
      }))
    ];

    programs = {
      bat.enable = true;
      bash.enable = true;
      btop.enable = true;

      direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
          package = overrideNix pkgs.nix-direnv;
        };
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
      ripgrep.enable = true;
      ssh.enable = true;
      vim.enable = true;
    };

    xdg.enable = true;
  };
}
