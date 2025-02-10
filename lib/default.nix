{ config, lib, ... }:

let
  self = config.flake.lib;
in

{

  flake.lib = {
    /**
      Get the derivation attribute of a configuration if needed

      # Type

      ```
      derivationFrom :: AttrSet -> Derivation
      ```

      # Arguments

      - [set] A system/home configuration or regular derivation
    */
    derivationFrom =
      deriv:
      if lib.isDerivation deriv then
        deriv
      else
        deriv.config.system.build.toplevel or deriv.activationPackage;

    /**
      Check if a derivation or configuration is compatible with the current system

      # Type

      ```
      isCompatible :: String -> Derivation -> Bool
      ```

      # Arguments

      - [system] System to check against
      - [derivation] Derivation to check
    */
    isCompatibleWith = system: deriv: (deriv.pkgs or deriv).stdenv.hostPlatform.system == system;

    /**
      Flatten nested derivations from an attribute set

      Mainly for use with making Flake outputs work in `checks`

      # Example

      ```nix
      collectNestedDerivations { nixosConfigurations = { my-machine = { }; }; }
      => { nixosConfigurations-my-machine = { }; }

      # Type

      ```
      collectNestedDerivations :: String -> AttrSet -> AttrSet
      ```

      # Arguments

      - [system] System to collect derivations for
      - [set] Set of (single-level) nested derivations
    */
    collectNestedDerivationsFor =
      system:

      lib.foldlAttrs (
        acc: attrType: values:

        acc
        // lib.mapAttrs' (
          attrName: value: lib.nameValuePair "${attrType}-${attrName}" (self.derivationFrom value)
        ) (lib.filterAttrs (lib.const (self.isCompatibleWith system)) values)
      ) { };
  };
}
