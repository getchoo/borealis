{ config, lib, ... }:

let
  cfg = config.borealis.users.system;
in

{
  options.borealis.users.system = {
    enable = lib.mkEnableOption "an untrusted system user";
  };

  config = lib.mkIf cfg.enable {
    users.users.${config.networking.hostName} = {
      isNormalUser = true;
    };
  };
}
