{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  isWsl = osConfig.wsl.enable or false;
in

{
  programs = {
    git = {
      settings = {
        init = {
          defaultBranch = "main";
        };

        user = {
          email = "getchoo@tuta.io";
          name = "Seth Flynn";
        };
      };

      signing = {
        format = "ssh";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBzp61t3KlcZZorMGzCHJJmiCoAEJsdHgYww80LmwkPd";
        signByDefault = true;
        signer = if isWsl then "op-ssh-sign-wsl.exe" else lib.getExe' pkgs._1password-gui "op-ssh-sign";
      };
    };

    riff = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
