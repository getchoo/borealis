{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.seth.programs.git;
in
{
  imports = [ inputs.getchpkgs.homeModules.riff ];

  options.seth.programs.git = {
    enable = lib.mkEnableOption "Git configuration settings" // {
      default = config.seth.enable;
      defaultText = lib.literalExpression "config.seth.enable";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.git-branchless ];

    programs.git = {
      enable = true;

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
  };
}
