let
  lib = import <nixpkgs/lib>;
in

args:

lib.evalModules (
  {
    modules = args.modules ++ [ ./module.nix ];
    class = "agenix";
  }
  // lib.removeAttrs args [ "modules" ]
)
