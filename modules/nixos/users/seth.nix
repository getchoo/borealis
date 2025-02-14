{
  config,
  lib,
  secretsDir,
  ...
}:

let
  cfg = config.borealis.users.seth;
in

{
  options.borealis.users.seth = {
    manageSecrets = lib.mkEnableOption "automatic management of secrets" // {
      default = true;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.manageSecrets) {
      age.secrets = {
        sethPassword.file = secretsDir + "/sethPassword.age";
      };

      users.users.seth = {
        hashedPasswordFile = lib.mkDefault config.age.secrets.sethPassword.path;
      };
    })
  ];
}
