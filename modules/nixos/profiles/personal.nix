{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.profiles.personal;
in

{
  options.profiles.personal = {
    enable = lib.mkEnableOption "the Personal profile";
  };

  config = lib.mkIf cfg.enable {
    traits = {
      home-manager.enable = true;

      secrets = {
        enable = true;
        secretsDir = inputs.self + "/secrets/personal";
      };
      tailscale.enable = true;

      users = {
        seth.enable = true;
      };
    };
  };
}
