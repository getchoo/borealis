{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.borealis.profiles.personal;
in

{
  config = lib.mkIf cfg.enable {
    _module.args = {
      secretsDir = inputs.self + "/secrets/personal";
    };

    programs = {
      nix-ld.enable = lib.mkDefault true;
    };

    system.rebuild.enableNg = true;
  };
}
