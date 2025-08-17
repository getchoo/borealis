{ inputs, ... }:

{
  imports = [ inputs.determinate.nixosModules.default ];
}
