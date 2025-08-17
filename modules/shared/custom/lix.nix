{
  config,
  lib,
  inputs',
  ...
}:

let
  cfg = config.borealis.lix;
in

{
  options.borealis.lix = {
    enable = lib.mkEnableOption "the Lix implementation of Nix by default";
  };

  config = lib.mkIf cfg.enable {
    nix.package = lib.mkForce inputs'.lix-module.packages.default;
  };
}
