{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = ".git/config";

      programs = {
        deadnix.enable = true;
        just.enable = true;
        nixfmt.enable = true;
      };
    };
  };
}
