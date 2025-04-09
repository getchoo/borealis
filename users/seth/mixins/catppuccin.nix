{ inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    accent = "mauve";
    flavor = "mocha";

    chromium.enable = false;
  };
}
