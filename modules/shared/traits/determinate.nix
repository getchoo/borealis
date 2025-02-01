{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.traits.determinate;

  nixPackage = inputs.determinate.inputs.nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
  options.traits.determinate = {
    enable = lib.mkEnableOption "Determinate with a bit less Determinate";

    determinate-nix.enable = lib.mkEnableOption "Determinate Nix";
    determinate-nixd.enable = lib.mkEnableOption "determinate-nixd" // {
      default = true;
    };
    flakehub-cache.enable = lib.mkEnableOption "the FlakeHub cache" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.determinate-nix.enable {
        nix.package = lib.mkDefault nixPackage;
      })

      (lib.mkIf cfg.flakehub-cache.enable {
        nix.settings = {
          extra-substituters = [ "https://cache.flakehub.com" ];
          extra-trusted-public-keys = [
            "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
            "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
            "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
            "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
            "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
            "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
            "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
            "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
          ];
        };
      })
    ]
  );
}
