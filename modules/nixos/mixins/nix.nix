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

    settings = {
      nix-path = lib.mapAttrsToList (name: lib.const "${name}=/run/current-system/inputs/${name}") inputs;

      trusted-users = [
        "@wheel"
      ];
    };
  };

  nixpkgs.config.allowAliases = false;

  system.systemBuilderCommands = "ln -s ${flakeInputs} $out/inputs";
}
