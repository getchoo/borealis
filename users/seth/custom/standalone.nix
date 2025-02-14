{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.seth.standalone;

  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in

{

  options.seth.standalone = {
    enable = lib.mkEnableOption "standalone configuration mode";
  };

  config = lib.mkIf cfg.enable {
    # This won't be set in standalone configurations
    _module.args.osConfig = { };

    # Make sure we can switch & update
    programs.home-manager.enable = true;

    home = {
      username = "seth";
      homeDirectory = (if isDarwin then "/Users" else "/home") + "/${config.home.username}";
    };

    nix = {
      package = lib.mkDefault pkgs.nix;
    };
  };
}
