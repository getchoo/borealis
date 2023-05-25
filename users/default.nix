{
  inputs,
  myLib,
  ...
}: {
  perSystem = {system, ...}: let
    inherit (myLib.configs) mkHMUser;
  in {
    homeConfigurations = {
      seth = mkHMUser {
        name = "seth";
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = with inputs; [nur.overlay getchoo.overlays.default];
        };
      };
    };
  };
}
