{
  config,
  lib,
  inputs,
  ...
}:

let
  # Why? I have no idea.
  disallowedSettings = [
    "always-allow-substitutes"
    "bash-prompt-prefix"
    "netrc-file"
    "ssl-cert-file"
    "upgrade-nix-store-path-url"
  ];
in

{
  imports = [ inputs.determinate.darwinModules.default ];

  # Pollyfill from NixOS module
  options.determinate = {
    enable = lib.mkEnableOption "Determinate Nix";
  };

  config = lib.mkIf config.determinate.enable {
    determinate-nix.customSettings = lib.removeAttrs config.nix.settings disallowedSettings;
  };
}
