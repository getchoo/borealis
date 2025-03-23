{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  # TODO: Remove this nonsense when all implementations remove repl-flake
  hasReplFlake =
    lib.versionOlder config.nix.package.version "2.22.0" # repl-flake was removed in nix 2.22.0
    || (
      lib.versionAtLeast config.nix.package.version "2.90.0" # but not in Lix
      && lib.versionOlder config.nix.package.version "2.93.0" # until 2.93
    );

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

          extra-trusted-substituters = [
            "https://getchoo.cachix.org"
            "https://nix-community.cachix.org?priority=50"
          ];

          extra-trusted-public-keys = [
            "getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          use-xdg-base-directories = true;
        };

        gc = {
          automatic = lib.mkDefault true;
          options = lib.mkDefault "--delete-older-than 5d";
        };

        registry =
          lib.mapAttrs (lib.const (flake: {
            inherit flake;
          })) inputs
          // {
            nixpkgs = lib.mkForce { flake = inputs.nixpkgs; };
          };

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
