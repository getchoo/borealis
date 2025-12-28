{ inputs, ... }:

{
  imports = [ inputs.lix-module.nixosModules.default ];
}
