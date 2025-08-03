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
  options.borealis.profiles.personal = {
    enable = lib.mkEnableOption "the Personal profile";
  };

  config = lib.mkIf cfg.enable {
    _module.args = {
      secretsDir = inputs.self + "/secrets/personal";
    };

    borealis = {
      users = {
        seth.enable = lib.mkDefault true;
      };
    };

    # Use latest Nix
    nixpkgs.overlays = [ (_: prev: { nix = prev.nixVersions.latest; }) ];

    programs = {
      nix-ld.enable = true;
    };

    services = {
      tailscale.enable = lib.mkDefault true;
    };

    system.rebuild.enableNg = true;
  };
}
