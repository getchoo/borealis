inputs: [
  inputs.getchvim.overlays.default
  inputs.nixd.overlays.default

  # Make sure nixd actually uses nix stuff from local `pkgs`
  (
    final: prev:

    let
      nixComponents = final.nixVersions.nixComponents_2_30;
    in

    {
      nixd = prev.nixd.override (prev': {
        inherit nixComponents;
        nixt = prev'.nixt.override { inherit nixComponents; };
      });
    }
  )
]
