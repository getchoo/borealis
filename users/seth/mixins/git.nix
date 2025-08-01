{
  lib,
  ...
}:

{
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
  ];
}
