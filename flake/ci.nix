{ lib, self, ... }:

let
  # NOTE: This only flattens one level of attrs. It should probably be recursive
  flattenAttrs = lib.concatMapAttrs (
    prefix: lib.mapAttrs' (name: lib.nameValuePair "${prefix}-${name}")
  );

  mapCfgsToDrvs = lib.mapAttrs (lib.const (v: v.config.system.build.toplevel or v.activationPackage));
  filterCompatibleCfgs =
    system: lib.filterAttrs (lib.const (v: v.pkgs.stdenv.hostPlatform.system == system));
in

{
  perSystem =
    {
      system,
      self',
      ...
    }:

    let
      configurations = lib.mapAttrs (lib.const (v: mapCfgsToDrvs (filterCompatibleCfgs system v))) {
        inherit (self) nixosConfigurations homeConfigurations darwinConfigurations;
      };
    in

    {
      checks = flattenAttrs (
        configurations
        // {
          inherit (self') devShells;
        }
      );
    };
}
