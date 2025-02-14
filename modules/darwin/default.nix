{
  flake.darwinModules = {
    default = {
      imports = [
        ../shared
        ./defaults
        ./mixins
        ./profiles
        ./services
        ./users
      ];
    };
  };
}
