{
  flake.nixosModules = {
    default = {
      imports = [
        ../shared
        ./defaults
        ./mixins
        ./profiles
        ./services
        ./traits
      ];
    };
  };
}
