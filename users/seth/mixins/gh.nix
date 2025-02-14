{
  config,
  lib,
  ...
}:

{
  programs.gh = {
    enable = lib.mkDefault config.programs.git.enable;

    settings = {
      git_protocol = "https";
      editor = "nvim";
      prompt = "enabled";
    };

    gitCredentialHelper = {
      enable = true;
      hosts = [
        "https://github.com"
        "https://github.example.com"
      ];
    };
  };
}
