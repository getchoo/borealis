{
  description = "Getchoo's Flake for system configurations";

  nixConfig = {
    extra-substituters = [ "https://getchoo.cachix.org" ];
    extra-trusted-public-keys = [ "getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE=" ];
  };

  outputs =
    inputs:

    let
      flakeModules = import ./modules/flake;
    in

    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        flakeModules.colmena
        inputs.getchpkgs.flakeModules.checks
        inputs.getchpkgs.flakeModules.configurations

        ./flake
        ./lib
        ./modules
        ./openwrt
        ./systems
        ./users
      ];

      flake = { inherit flakeModules; };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Use their robots.txt
    codeberg-infra = {
      url = "https://codeberg.org/Codeberg-Infrastructure/build-deploy-forgejo/archive/codeberg-10.tar.gz";
      flake = false;
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        stable.follows = "";
        nix-github-actions.follows = "";
        flake-compat.follows = "";
      };
    };

    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix.follows = "";
      };
    };

    getchpkgs = {
      url = "github:getchoo/getchpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    getchvim = {
      url = "github:getchoo/getchvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    krunner-nix = {
      url = "github:pluiedev/krunner-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "";
        pre-commit-hooks-nix.follows = "";
      };
    };

    moyai-bot = {
      url = "github:getchoo/moyai-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };

    nixpkgs-tracker-bot = {
      url = "github:getchoo/nixpkgs-tracker-bot";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-filter.follows = "getchvim/nix-filter";
        treefmt-nix.follows = "";
      };
    };

    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "agenix/systems";
      };
    };
  };
}
