{ lib, inputs, ... }:

{
  imports = [ inputs.lix-module.nixosModules.default ];

  # I prefer this to be opt-in for my systems
  lix.enable = lib.mkDefault false;
}
