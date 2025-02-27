{ config, lib, ... }:

{
  assertions = [
    {
      assertion =
        config.programs.jujutsu.enable -> (config.programs.git.enable && config.programs.gh.enable);
      message = "`programs.git` and `programs.gh` are required to use `programs.jujutsu`";
    }
  ];

  programs = {
    jujutsu = {
      enable = lib.mkDefault config.programs.git.enable;

      settings = {
        user = {
          name = "Seth Flynn";
          email = "getchoo@tuta.io";

          # https://github.com/jj-vcs/jj/issues/4979
          git.subprocess = true;
        };

        signing = {
          sign-all = true;
          backend = "gpg";
          key = "D31BD0D494BBEE86";
        };
      };
    };
  };
}
