{
  config,
  lib,
  inputs',
  ...
}:

{
  config = lib.mkIf config.determinate.enable {
    nix.package = lib.mkForce inputs'.dix.packages.default;
  };
}
