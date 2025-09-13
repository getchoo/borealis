inputs: [
  inputs.getchvim.overlays.default
  inputs.nixd.overlays.default

  # Make sure nixd actually uses nix stuff from local `pkgs`
  (
    final: prev:

    let
      inherit (final) lib;
      latestNixVersionSuffix =
        lib.versions.majorMinor final.nixVersions.latest.version |> lib.replaceStrings [ "." ] [ "_" ];
      nixComponents = final.nixVersions."nixComponents_${latestNixVersionSuffix}";
    in

    {
      nixd = prev.nixd.override (prev': {
        inherit nixComponents;
        nixt = prev'.nixt.override { inherit nixComponents; };
      });
    }
  )
]
