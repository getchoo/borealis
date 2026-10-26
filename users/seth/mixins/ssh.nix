{
  osConfig,
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  isWsl = osConfig.wsl.enable or false;
in

{
  config = lib.mkMerge [
    {
      programs.ssh = {
        package = osConfig.programs.ssh.package or options.programs.ssh.package.default;

        enableDefaultConfig = false;

        settings =
          let
            sshDir = "${config.home.homeDirectory}/.ssh";
          in
          {
            # git forges
            "codeberg.org" = {
              Hostname = "codeberg.org";
              User = "git";
              IdentityFile = "${sshDir}/codeberg";
            };

            # linux packaging
            "aur.archlinux.org" = {
              Hostname = "aur.archlinux.org";
              User = "aur";
              IdentityFile = "${sshDir}/aur";
            };

            "pagure.io" = {
              Hostname = "pagure.io";
              User = "git";
              IdentityFile = "${sshDir}/copr";
            };

            # macstadium m1
            "mini.scrumplex.net" = {
              Hostname = "mini.scrumplex.net";
              User = "bob-the-builder";
              IdentityFile = "${sshDir}/macstadium";
            };
          };
      };
    }

    (lib.mkIf config.programs.ssh.enable {
      services.ssh-agent.enable = lib.mkDefault (isLinux && (!isWsl));
    })
  ];
}
