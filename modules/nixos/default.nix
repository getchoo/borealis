{
  flake.nixosModules = {
    default = {
      imports = [
        ../shared
        ./custom
        ./mixins
        ./profiles
        ./users
      ];
    };
  };
}
