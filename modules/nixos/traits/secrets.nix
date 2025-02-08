{
  config,
  lib,
  inputs,
  secretsDir,
  ...
}:
let
  cfg = config.traits.secrets;
in
{
  options.traits.secrets = {
    enable = lib.mkEnableOption "secrets management";

    hostUser = lib.mkEnableOption "manager secrets for host user (see `profiles.server.hostUser`)" // {
      default = config.profiles.server.hostUser;
      defaultText = "config.profiles.server.hostUser";
    };

    secretsDir = lib.mkOption {
      type = lib.types.path;
      default = inputs.self + "/secrets/${config.networking.hostName}";
      defaultText = lib.literalExample "inputs.self + \"/secrets/\${config.networking.hostName}\"";
      description = "Path to your `secrets.nix` subdirectory.";
    };
  };

  imports = [ inputs.agenix.nixosModules.default ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        _module.args = {
          inherit (cfg) secretsDir;
        };

        age = {
          identityPaths = [ "/etc/age/key" ];
        };
      }

      (lib.mkIf (config.profiles.server.enable && cfg.hostUser) {
        age.secrets = {
          userPassword.file = secretsDir + "/userPassword.age";
        };

        users.users.${config.networking.hostName} = {
          hashedPasswordFile = config.age.secrets.userPassword.path;
        };
      })
    ]
  );
}
