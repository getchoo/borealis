{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.getchpkgs.homeModules.riff ];

  config = lib.mkMerge [
    {
      programs.git = {
        riff.enable = true;

        extraConfig = {
          init = {
            defaultBranch = "main";
          };
        };

        signing = {
          key = "D31BD0D494BBEE86";
          signByDefault = true;
        };

        userEmail = "getchoo@tuta.io";
        userName = "Seth Flynn";
      };
    }

    (lib.mkIf config.programs.git.enable {
      home.packages = [ pkgs.git-branchless ];
    })
  ];
}
