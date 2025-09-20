{
  # Re-export the patched Lix
  perSystem =
    { pkgs, ... }:

    {
      packages = { inherit (pkgs) lix; };
    };

  flake.overlays.lix-patches = final: prev: {
    lix =
      (prev.lix.override (old: {
        # Part of lix#3880 below
        boehmgc = old.boehmgc.overrideAttrs (oldAttrs: {
          NIX_CFLAGS_COMPILE =
            final.lib.optional (oldAttrs ? "NIX_CFLAGS_COMPILE") oldAttrs.NIX_CFLAGS_COMPILE
            ++ [ "-DINITIAL_MARK_STACK_SIZE=1048576" ]
            |> toString;
        });
      })).overrideAttrs
        (oldAttrs: {
          patches = oldAttrs.patches or [ ] ++ [
            # nix flake check: Skip substitutable derivations
            # https://gerrit.lix.systems/c/lix/+/3841
            (final.fetchpatch2 {
              name = "skip-substitutable-derivations.patch";
              url = "https://gerrit.lix.systems/changes/lix~3841/revisions/8/patch?download&raw";
              excludes = [ "doc/manual/change-authors.yml" ]; # Conflicts with lix#3879 below
              hash = "sha256-LKtEAGYpKzCAbgpsYwDyUF0LFZcCXec+D3nxGs+M2eg=";
            })

            # libexpr: warn when encountering IFD with `warn-import-from-derivation`
            # https://gerrit.lix.systems/c/lix/+/3879
            (final.fetchpatch2 {
              name = "warn-import-from-derivation.patch";
              url = "https://gerrit.lix.systems/changes/lix~3879/revisions/9/patch?download&raw";
              hash = "sha256-Zvht06fqYLQSkUs4Ktljb2BHVGmdvGgv5WYm9hgZ7u0=";
            })

            # libexpr: enable parallel marking in boehmgc
            # https://gerrit.lix.systems/c/lix/+/3880
            (final.fetchpatch2 {
              name = "enable-parallel-marking.patch";
              url = "https://gerrit.lix.systems/changes/lix~3880/revisions/2/patch?download&raw";
              excludes = [ "package.nix" ];
              hash = "sha256-bJ73Z0boBm92J5LgxS5pPoQqKfz4A8f4R1TGrAaQWhk=";
            })
          ];
        });
  };
}
