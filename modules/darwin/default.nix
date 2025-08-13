{
  flake.darwinModules = {
    default = {
      imports = [
        ../shared
        ./custom
        ./mixins
        ./profiles
      ];
    };
  };
}
