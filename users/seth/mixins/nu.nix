{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = "catppuccin-${config.catppuccin.flavor}";
in

{
  config = lib.mkMerge [
    {
      programs.nushell = {
        configFile.text = ''
          def "nixgc" [] {
            sudo nix-collect-garbage -d; nix-collect-garbage -d
          }
        '';

        envFile.text = ''
          use ${pkgs.nu_scripts}/share/nu_scripts/themes/nu-themes/${theme}.nu
          $env.config.color_config = (${theme})
        '';

        inherit (config.home) shellAliases;
      };
    }

    (lib.mkIf config.programs.nushell.enable {
      programs = {
        # Wrap it with bash
        bash.initExtra = lib.mkAfter ''
          if [[ $(ps --no-header --pid=$PPID --format=comm) != "nu" && -z ''${BASH_EXECUTION_STRING} ]]; then
             exec ${lib.getExe config.programs.nushell.package}
          fi
        '';

        # builtin `ls` is good here!
        eza.enable = lib.mkForce false;
      };
    })
  ];
}
