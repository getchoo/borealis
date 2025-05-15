{
  perSystem =
    { pkgs, ... }:

    {
      terranix.terranixConfigurations.borealis = {
        modules = [
          ./modules

          ./dns.nix
          ./hardware.nix
          ./oci.nix
          ./pages.nix
          ./providers.nix
          ./rulesets.nix
          ./tailscale.nix
          ./vars.nix
        ];

        terraformWrapper.package = pkgs.opentofu;
      };
    };
}
