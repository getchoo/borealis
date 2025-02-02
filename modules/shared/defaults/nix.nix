{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  # TODO: remove this nonsense when all implementations remove repl-flake
  hasReplFlake =
    lib.versionOlder config.nix.package.version "2.22.0" # repl-flake was removed in nix 2.22.0
    || lib.versionAtLeast config.nix.package.version "2.90.0"; # but not in lix yet

  hasAlwaysAllowSubstitutes = lib.versionAtLeast config.nix.package.version "2.19.0";
in
{
  config = lib.mkMerge [
    {
      nix = {
        settings = {
          auto-optimise-store = lib.mkDefault isLinux;
          experimental-features = [
            "nix-command"
            "flakes"
            "auto-allocate-uids"
          ];
        };

        gc = {
          automatic = lib.mkDefault true;
          options = lib.mkDefault "--delete-older-than 2d";
        };

        registry = lib.mapAttrs (lib.const (
          flake:
          lib.mkForce {
            inherit flake;
          }
        )) inputs;

        # See comment below
        nixPath = lib.mapAttrsToList (name: lib.const "${name}=flake:${name}") inputs;
      };

      nixpkgs = {
        config.allowUnfree = lib.mkDefault true;
      };
    }

    (lib.mkIf hasReplFlake {
      nix.settings.experimental-features = [ "repl-flake" ];
    })

    (lib.mkIf hasAlwaysAllowSubstitutes {
      nix.settings.always-allow-substitutes = true;
    })
  ];
}
