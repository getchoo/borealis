{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.lix-module.nixosModules.default ];

  # I prefer this to be opt-in for my systems
  lix.enable = lib.mkDefault false;

  nixpkgs.overlays = lib.mkIf config.lix.enable [ inputs.self.overlays.lix-patches ];
}
