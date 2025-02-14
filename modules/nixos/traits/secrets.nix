{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.traits.secrets;
in

{
  options.traits.secrets = {
    enable = lib.mkEnableOption "secrets management";

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
    ]
  );
}
