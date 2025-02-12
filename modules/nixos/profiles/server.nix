{
  config,
  lib,
  inputs',
  ...
}:
let
  cfg = config.profiles.server;

  # 2^30
  # Why doesn't nix have a `pow`???
  gb = 1024 * 1024 * 1024;
  minimumStorageKb = 15 * gb;
in
{
  options.profiles.server = {
    enable = lib.mkEnableOption "the Server profile";

    hostUser = lib.mkEnableOption "a default interactive user" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # All servers are most likely on stable, so we want to pull in some newer packages from time to time
        _module.args.unstable = inputs'.nixpkgs.legacyPackages;

        boot.tmp.cleanOnBoot = lib.mkDefault true;

        # We don't need it here
        documentation.enable = false;

        environment.defaultPackages = lib.mkForce [ ];

        nix.gc = {
          dates = "*:0/30"; # Every 30 minutes
          # GC to stay above minimumStorageBytes
          options = toString [
            "--delete-older-than 5d"
            "--max-freed \"$((${toString minimumStorageKb} - 1024 * $(df -k --output=avail /nix/store | tail -n 1)))\""
          ];
        };

        services.comin.enable = true;

        traits = {
          secrets.enable = true;
          tailscale = {
            enable = true;
            ssh.enable = true;
          };
          zram.enable = true;
        };
      }

      (lib.mkIf cfg.hostUser {
        # Hardening access to `nix` as no other users *should* ever really touch it
        nix.settings.allowed-users = [ config.networking.hostName ];

        users.users.${config.networking.hostName} = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };
      })
    ]
  );
}
