{ lib, inputs, ... }:

{
  imports = [ inputs.determinate.darwinModules.default ];

  # I prefer this to be opt-in for my systems
  determinate.enable = lib.mkDefault false;
}
