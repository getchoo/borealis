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
    borealis = {
      users = {
        seth.enable = true;
      };
    };

    services = {
      tailscale.enable = true;
    };

    traits = {
      secrets = {
        enable = true;
        secretsDir = inputs.self + "/secrets/personal";
      };
    };
  };
}
