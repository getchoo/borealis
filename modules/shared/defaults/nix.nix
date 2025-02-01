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

  # Use systemd-tmpfiles on Linux
  nixPathFromInput =
    name: input: "${name}=${if isLinux then "/etc/nix/inputs/${name}" else input.outPath}";
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

        # See comment below
        nixPath = lib.mapAttrsToList nixPathFromInput inputs;
      };

      nixpkgs = {
        config.allowUnfree = lib.mkDefault true;
        # The `flake:` syntax in `$NIX_PATH` seems to do some weird copying on Nix 2.24
        flake.setNixPath = false;
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
