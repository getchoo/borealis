{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  nixVersion = config.nix.package.version;
  nixAtLeast = lib.versionAtLeast nixVersion;
  nixOlder = lib.versionOlder nixVersion;

  isDix = config.nix.package.pname == "determinate-nix" || nixAtLeast "3.0.0";
  isLix = config.nix.package.pname == "lix";

  hasAlwaysAllowSubstitutes = nixAtLeast "2.19.0";
  hasFlakesByDefault = isDix;
  hasLazyTrees = isDix && nixAtLeast "3.5.0";
  hasLixSubcommand = isLix && nixAtLeast "2.93.0";
  hasParallelEval = isDix && nixAtLeast "3.11.1";
  hasPipeOperator = isLix && nixAtLeast "2.91.0";
  hasPipeOperators = !isLix && nixAtLeast "2.24.0";
  hasReplFlake =
    nixOlder "2.22.0" # repl-flake was removed in Nix 2.22.0
    || (isLix && nixOlder "2.93.0"); # but not in Lix until 2.93
in

{
  nix = {
    gc = {
      automatic = lib.mkDefault (!isDix && config.nix.enable);
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

      (lib.mkIf hasParallelEval {
        experimental-features = [ "parallel-eval" ];
        eval-cores = 0;
      })

      (lib.mkIf hasPipeOperator {
        experimental-features = [ "pipe-operator" ];
      })

      (lib.mkIf hasPipeOperators {
        experimental-features = [ "pipe-operators" ];
      })

      (lib.mkIf hasReplFlake {
        experimental-features = [ "repl-flake" ];
      })
    ];
  };

  nixpkgs = {
    config.allowUnfree = lib.mkDefault true;
  };
}
