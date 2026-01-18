{
  config,
  lib,
  ...
}:

{
  config = lib.mkMerge [
    {
      programs.fish = {
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
