{ inputs, ... }:

{
  imports = [ inputs.comin.nixosModules.comin ];

  services.comin = {
    remotes = [
      {
        name = "origin";
        url = "https://github.com/getchoo/borealis.git";
      }
    ];
  };
}
