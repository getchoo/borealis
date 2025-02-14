{
  flake.darwinModules = {
    default = {
      imports = [
        ../shared
        ./custom
        ./defaults
        ./mixins
        ./profiles
      ];
    };
  };
}
