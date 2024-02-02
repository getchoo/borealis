{
  lib,
  self,
  ...
}: {
  flake.hydraJobs = let
    ciSystems = ["x86_64-linux"];

    getOutputs = lib.getAttrs ciSystems;

    mapCfgsToDerivs = lib.mapAttrs (_: cfg: cfg.activationPackage or cfg.config.system.build.toplevel);
    getCompatibleCfgs = lib.filterAttrs (_: cfg: lib.elem cfg.pkgs.system ciSystems);
    getConfigurations = type: mapCfgsToDerivs (getCompatibleCfgs self."${type}Configurations");
  in
    {
      checks = getOutputs self.checks;
      devShells = getOutputs self.devShells;
    }
    // lib.genAttrs ["nixos" "home"] getConfigurations;
}
