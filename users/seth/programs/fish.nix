{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.seth.programs.fish;
in
{
  options.seth.programs.fish = {
    enable = lib.mkEnableOption "Fish configuration";
    hydro.enable = lib.mkEnableOption "Hydra prompt" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.fish = {
          enable = true;

          functions = {
            last_history_item.body = "echo $history[1]";
          };

          shellAbbrs = {
            nixgc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
            "!!" = {
              position = "anywhere";
              function = "last_history_item";
            };
          };
        };
      }

      (lib.mkIf cfg.hydro.enable {
        programs.fish = {
          interactiveShellInit = ''
            set --global hydro_symbol_prompt ">"

            set --global hydro_color_duration $fish_color_end
            set --global hydro_color_git cba6f7
            set --global hydro_color_prompt $fish_color_cwd
            set --global hydro_color_pwd $fish_color_user
          '';

          plugins = [
            {
              name = "hydro";
              inherit (pkgs.fishPlugins.hydro) src;
            }
          ];
        };
      })

      # TODO: do i still need this weird sourcing?
      (lib.mkIf config.seth.standalone.enable {
        programs.fish = {
          interactiveShellInit = ''
            set -l nixfile ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.fish
            if test -e $nixfile
            	source $nixfile
            end
          '';
        };
      })
    ]
  );
}
