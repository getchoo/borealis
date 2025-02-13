{ inputs, ... }:

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  catppuccin = {
    accent = "mauve";
    flavor = "mocha";

    # Don't use modules with IFD by default
    tty.enable = false;
  };
}
