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
        key = "D31BD0D494BBEE86";
        signByDefault = true;
      };
    };

    riff = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
