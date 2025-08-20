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

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        users.users.seth.shell = pkgs.fish;

        programs.fish.enable = true;

        home-manager.users.seth = {
          imports = [ (inputs.self + "/users/seth") ];
        };

        nixpkgs.overlays = import (inputs.self + "/users/seth/overlays.nix") inputs;
      }

      (lib.mkIf isDarwin {
        users.users.seth = {
          home = lib.mkDefault "/Users/seth";
        };
      })

      (lib.mkIf isLinux {
        users.users.seth = {
          extraGroups = [ "wheel" ];
          isNormalUser = true;
        };
      })
    ]
  );
}
