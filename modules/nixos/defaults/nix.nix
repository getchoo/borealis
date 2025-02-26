{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  flakeInputs = pkgs.linkFarm "flake-inputs" (
    lib.mapAttrs (lib.const (flake: flake.outPath)) inputs
  );
in

{
  nix = {
    channel.enable = lib.mkDefault false;

    nixPath = lib.mkForce (
      lib.mapAttrsToList (name: lib.const "${name}=/run/current-system/inputs/${name}") inputs
    );

    settings.trusted-users = [
      "@wheel"
    ];
  };

  nixpkgs.config.allowAliases = false;

  system.extraSystemBuilderCmds = ''
    ln -s ${flakeInputs} $out/inputs
  '';
}
