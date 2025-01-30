{
  flake.nixosModules = {
    default = {
      imports = [
        ../shared
        ./defaults
        ./desktop
        ./mixins
        ./profiles
        ./services
        ./traits
        ./tweaks
      ];
    };
  };
}
