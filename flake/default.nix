{
  imports = [
    ./ci.nix
    ./dev-shells.nix
  ];

  perSystem =
    { pkgs, ... }:

    {
      formatter = pkgs.nixfmt;
    };
}
