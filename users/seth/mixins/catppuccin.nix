{ options, inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    autoEnable = true;

    accent = "mauve";
    flavor = "mocha";

    chromium.enable = false;

    sources = options.catppuccin.sources.default;
  };
}
