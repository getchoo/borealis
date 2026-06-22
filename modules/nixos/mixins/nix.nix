{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  flakeInputs = lib.mapAttrs (lib.const toString) inputs |> pkgs.linkFarm "inputs";
in

{
  nix = {
    channel.enable = lib.mkDefault false;

    nixPath = lib.mapAttrsToList (name: lib.const "${name}=/run/current-system/inputs/${name}") inputs;

    settings.trusted-users = [
      "@wheel"
    ];
  };

  nixpkgs.config.allowAliases = false;

  system.extraSystemBuilderCmds = ''
    ln -s ${flakeInputs} $out/inputs
  '';
}
