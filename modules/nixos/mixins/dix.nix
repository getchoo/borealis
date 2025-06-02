{ lib, inputs, ... }:

{
  imports = [ inputs.determinate.nixosModules.default ];

  # I prefer this to be opt-in for my systems
  determinate.enable = lib.mkDefault false;
}
