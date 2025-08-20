{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.borealis.profiles.desktop;
in

{
  config = lib.mkIf cfg.enable {
    _module.args = {
      secretsDir = inputs.self + "/secrets/personal";
    };

    environment.systemPackages = lib.mkIf config.services.xserver.enable [
      pkgs.chromium
      pkgs.wl-clipboard
    ];

    nixpkgs.overlays = lib.mkIf config.services.xserver.enable [
      (final: prev: {
        chromium = prev.chromium.override {
          enableWideVine = final.config.allowUnfree;
        };

        # TODO: Unpin this when the latest version doesn't 404, lol
        widevine-cdm = prev.widevine-cdm.overrideAttrs (
          finalAttrs: _: {
            version = "4.10.2830.0";

            src = final.fetchzip {
              url = "https://dl.google.com/widevine-cdm/${finalAttrs.version}-linux-x64.zip";
              hash = "sha256-XDnsan1ulnIK87Owedb2s9XWLzk1K2viGGQe9LN/kcE=";
              stripRoot = false;
            };
          }
        );
      })
    ];

    programs = {
      nix-ld.enable = lib.mkDefault true;
    };
  };
}
