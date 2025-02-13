{
  flake.darwinModules = {
    default = {
      imports = [
        ../shared
        ./defaults
        ./desktop
        ./mixins
        ./profiles
        ./traits
      ];
    };
  };
}
