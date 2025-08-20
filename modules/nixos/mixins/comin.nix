{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.comin.nixosModules.comin ];

  config = lib.mkMerge [
    {
      services.comin = {
        package = pkgs.comin;
        remotes = [
          {
            name = "origin";
            url = "https://github.com/getchoo/borealis.git";
          }
        ];
      };
    }

    (lib.mkIf config.services.comin.enable {
      nixpkgs.overlays = [ inputs.comin.overlays.default ];
    })
  ];
}
