{
  flake.darwinModules = {
    default = {
      imports = [
        ../shared
        ./mixins
        ./profiles
      ];
    };
  };
}
