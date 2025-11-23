{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in

{
  config = lib.mkMerge [
    {
      programs.ssh = {
        package = pkgs.openssh;

        matchBlocks =
          let
            sshDir = "${config.home.homeDirectory}/.ssh";
          in
          {
            # git forges
            "codeberg.org" = {
              identityFile = "${sshDir}/codeberg";
              user = "git";
            };

            "github.com" = {
              identityFile = "${sshDir}/github";
              user = "git";
            };

            # linux packaging
            "aur.archlinux.org" = {
              identityFile = "${sshDir}/aur";
              user = "aur";
            };

            "pagure.io" = {
              identityFile = "${sshDir}/copr";
              user = "git";
            };

            # macstadium m1
            "mini.scrumplex.net" = {
              identityFile = "${sshDir}/macstadium";
              user = "bob-the-builder";
            };

            # servers
            "atlas".user = "atlas";
          };
      };
    }

    (lib.mkIf config.programs.ssh.enable {
      services.ssh-agent.enable = lib.mkDefault isLinux;
    })
  ];
}
