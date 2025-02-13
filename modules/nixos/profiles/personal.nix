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
    services = {
      tailscale.enable = true;
    };

    traits = {
      home-manager.enable = true;

      secrets = {
        enable = true;
        secretsDir = inputs.self + "/secrets/personal";
      };

      users = {
        seth.enable = true;
      };
    };
  };
}
