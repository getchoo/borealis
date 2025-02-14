{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.borealis.users.seth;

  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in

{
  options.borealis.users.seth = {
    enable = lib.mkEnableOption "Seth's user & home configurations";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.users.seth.shell = pkgs.fish;

      programs.fish.enable = true;

      home-manager.users.seth = {
        imports = [ (inputs.self + "/users/seth") ];
        seth = {
          enable = true;
          programs.fish.enable = true;
        };
      };
    })

    (lib.mkIf (cfg.enable && isDarwin) {
      users.users.seth = {
        home = lib.mkDefault "/Users/seth";
      };
    })

    (lib.mkIf (cfg.enable && isLinux) {
      users.users.seth = {
        extraGroups = [ "wheel" ];
        isNormalUser = true;
      };
    })
  ];
}
