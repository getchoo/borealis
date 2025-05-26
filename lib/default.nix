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

    /**
      Merge a list of attribute sets, recursively

      This is what you probably expect the base mergeAttrsList to do

      # Example

      ```nix
      mergeAttrsList' [ { foo = { bar = true; }; } { foo = { baz = false; }; } ]
      => { foo = { bar = true; baz = false; }; }
      ```

      # Type

      ```
      mergeAttrsList' :: List -> AttrSet
      ```

      # Arguments

      - [list] List of attribute sets to merge
    */
    mergeAttrsList' = lib.foldl' lib.recursiveUpdate { };

    /**
      Make the names of attributes in a set unqiue from those in another by adding a prefix

      # Example

      ```nix
      makeUniqueAttrNames "foo" { bar = true; baz = false; }
      => { "foo-bar" = true; "foo-baz" = false; }
      ```

      # Type

      ```
      makeUniqueAttrNames :: String -> AttrSet -> AttrSet
      ```

      # Arguments

      - [prefix] Prefix to add to attribute names
      - [attrset] Attribute set to operate on
    */
    makeUniqueAttrNames = prefix: lib.mapAttrs' (name: lib.nameValuePair "${prefix}-${name}");
  };
}
