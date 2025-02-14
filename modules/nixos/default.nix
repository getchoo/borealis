{
  flake.nixosModules = {
    default = {
      imports = [
        ../shared
        ./custom
        ./defaults
        ./mixins
        ./profiles
        ./users
      ];
    };
  };
}
