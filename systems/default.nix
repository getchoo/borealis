{ inputs, ... }:

{
  configurations = {
    nixos = {
      glados = {
        modules = [ ./glados ];
      };

      glados-wsl = {
        modules = [ ./glados-wsl ];
      };

      atlas = {
        modules = [ ./atlas ];
        builder = inputs.nixpkgs-stable.lib.nixosSystem;
      };
    };

    darwin = {
      caroline = {
        modules = [ ./caroline ];
      };
    };
  };
}
