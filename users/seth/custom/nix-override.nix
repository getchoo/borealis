{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.seth.nix-override;
in

{
  options.seth.nix-override = {
    enable = lib.mkEnableOption "the use of a non-default implementation of Nix";
    package = lib.mkPackageOption pkgs "lix" { };
  };

  config = lib.mkIf cfg.enable {
    nix.package = cfg.package;

    programs = {
      direnv.nix-direnv.package = pkgs.nix-direnv.override { nix = cfg.package; };
    };
  };
}
