{
  config,
  lib,
  secretsDir,
  ...
}:
let
  cfg = config.traits.users.seth;
in
{
  options.traits.users.seth = {
    manageSecrets = lib.mkEnableOption "automatic management of secrets" // {
      default = config.traits.secrets.enable;
      defaultText = lib.literalExpression "config.traits.secrets.enable";
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
