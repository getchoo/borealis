{
  config,
  lib,
  pkgs,
  secretsDir,
  inputs,
  inputs',
  ...
}:

let
  cfg = config.borealis.profiles.server;

  # 2^30
  # Why doesn't nix have a `pow`???
  gb = 1024 * 1024 * 1024;
  minimumStorageKb = 15 * gb;
in

{
  options.borealis.profiles.server = {
    enable = lib.mkEnableOption "the Server profile";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        _module.args = {
          # All servers are most likely on stable, so we want to pull in some newer packages from time to time
          unstable = inputs'.nixpkgs.legacyPackages;

          secretsDir = inputs.self + "/secrets/${config.networking.hostName}";
        };

        age.secrets = {
          discordWebhookURL.file = "${secretsDir}/discordWebhookURL.age";
          tailscaleAuthKey.file = "${secretsDir}/tailscaleAuthKey.age";
        };

        boot.tmp.cleanOnBoot = lib.mkDefault true;

        borealis.users = {
          system.enable = true;
        };

        # We don't need it here
        documentation.enable = false;

        environment = {
          defaultPackages = lib.mkForce [ ];
          systemPackages = with pkgs; [
            ghostty.terminfo
            rsync
          ];
        };

        nix.gc = {
          dates = "*:0/30"; # Every 30 minutes
          # GC to stay above minimumStorageBytes
          options = toString [
            "--delete-older-than 5d"
            "--max-freed \"$((${toString minimumStorageKb} - 1024 * $(df -k --output=avail /nix/store | tail -n 1)))\""
          ];
        };

        services = {
          systemd-discord-notifier = {
            enable = true;

            content = ''
              # 🚨 %i.service failed! 🚨
              <@746501080409702461>
            '';

            webhookURLFile = config.age.secrets.discordWebhookURL.path;
          };

          tailscale = {
            enable = true;

            authKeyFile = config.age.secrets.tailscaleAuthKey.path;
            extraUpFlags = [ "--ssh" ];
          };
        };

        system.autoUpgrade = {
          enable = true;

          dates = "hourly";
          flake = "github:getchoo/borealis#${config.networking.hostName}";
          flags = [ "--refresh" ];
        };

        # I use exclusively Tailscale auth on some machines
        users.allowNoPasswordLogin = true;

        zramSwap.enable = true;
      }

      (lib.mkIf config.borealis.users.system.enable {
        # Hardening access to `nix` as no other users *should* ever really touch it
        nix.settings.allowed-users = [ config.networking.hostName ];
      })
    ]
  );
}
