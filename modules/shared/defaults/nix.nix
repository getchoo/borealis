{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  isDix = config.nix.package.pname == "determinate-nix";
  isLix = config.nix.package.pname == "lix";
  nixVersion = config.nix.package.version;

  hasAlwaysAllowSubstitutes = lib.versionAtLeast nixVersion "2.19.0";

  # TODO: Remove this nonsense when all implementations remove repl-flake
  hasReplFlake =
    lib.versionOlder nixVersion "2.22.0" # repl-flake was removed in Nix 2.22.0
    || (
      lib.versionAtLeast nixVersion "2.90.0" # but not in Lix
      && lib.versionOlder nixVersion "2.93.0" # until 2.93
    );

  hasFlakesByDefault = isDix;
  hasLazyTrees = isDix && lib.versionAtLeast nixVersion "3.5.0";
  hasLixSubcommand = isLix && lib.versionAtLeast nixVersion "2.93.0";
in

{
  config = {
    nix = {
      gc = {
        automatic = lib.mkDefault true;
        options = lib.mkDefault "--delete-older-than 5d";
      };

      nixPath = lib.mapAttrsToList (name: lib.const "${name}=flake:${name}") inputs;

      registry =
        lib.mapAttrs (lib.const (flake: {
          inherit flake;
        })) inputs
        // {
          nixpkgs = lib.mkForce { flake = inputs.nixpkgs; };
        };

      settings = lib.mkMerge [
        {
          auto-optimise-store = lib.mkDefault isLinux;
          experimental-features = [
            "auto-allocate-uids"
            "no-url-literals"
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
        }

        (lib.mkIf hasAlwaysAllowSubstitutes {
          always-allow-substitutes = true;
        })

        (lib.mkIf (!hasFlakesByDefault) {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        })

        (lib.mkIf hasLazyTrees {
          lazy-trees = true;
        })

        (lib.mkIf hasLixSubcommand {
          experimental-features = [ "lix-custom-sub-commands" ];
        })

        (lib.mkIf hasReplFlake {
          experimental-features = [ "repl-flake" ];
        })
      ];
    };

    nixpkgs = {
      config.allowUnfree = lib.mkDefault true;
    };
  };
}
