{ config, lib, ... }:

{
  config = lib.mkMerge [
    {
      programs.bash = {
        historyFile = "${config.xdg.stateHome}/bash/history";
        historyFileSize = 1000;
        historySize = 100;

        shellOptions = [
          "cdspell"
          "checkjobs"
          "checkwinsize"
          "dirspell"
          "globstar"
          "histappend"
          "no_empty_cmd_completion"
        ];
      };
    }

    # TODO: find out if i need this anymore with standalone HM
    (lib.mkIf config.seth.standalone.enable {
      programs.bash = {
        bashrcExtra = ''
          nixfile=${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh
          [ -e "$nixfile" ] && source "$nixfile"
        '';
      };
    })
  ];
}
