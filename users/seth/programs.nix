{
  config,
  pkgs,
  inputs,
  inputs',
  ...
}:

{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];

  config = {
    catppuccin.enable = true;

    home.packages = with pkgs; [
      (
        let
          getchvim = inputs'.getchvim.packages.default;
        in
        # remove desktop file
        pkgs.symlinkJoin {
          name = "${getchvim.name}-nodesktop";
          paths = [ getchvim ];
          postBuild = ''
            rm -rf $out/share/{applications,icons}
          '';
        }
      )
      (nurl.override { nix = config.nix.package; })

      hydra-check
      nixfmt-rfc-style
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
      nix-index-database.comma.enable = true;
      ripgrep.enable = true;
      ssh.enable = true;
      vim.enable = true;
    };

    xdg.enable = true;
  };
}
