{ pkgs, ... }:

{
  assertions = [
    {
      assertion = pkgs.overlays == [ ];
      message = "nixpkgs overlays are not allowed in my configurations.";
    }
  ];
}
