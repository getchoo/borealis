{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = ".git/config";

      programs = {
        actionlint.enable = true;
        deadnix.enable = true;
        hclfmt.enable = true;
        just.enable = true;
        nixfmt.enable = true;
      };
    };
  };
}
