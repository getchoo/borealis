{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkMerge [
    {
      programs.fish = {
        functions = {
          last_history_item.body = "echo $history[1]";
        };

        interactiveShellInit = ''
          set --global hydro_symbol_prompt ">"

          set --global hydro_color_duration $fish_color_end
          set --global hydro_color_error $fish_color_error
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

        shellAbbrs = {
          nixgc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
          "!!" = {
            position = "anywhere";
            function = "last_history_item";
          };
        };
      };
    }

    # TODO: Do i still need this weird sourcing?
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
  ];
}
