{
  config,
  lib,
  inputs',
  ...
}:

let
  cfg = config.borealis.determinate;

  package = inputs'.determinate.packages.default;
in

{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.determinate-nixd.enable {
        assertions = [
          {
            assertion = config.nix.daemon;
            message = "`nix.daemon` must be `true` when using `traits.determinate`";
          }

          {
            assertion = !config.services.nix-daemon.enable;
            message = "`services.nix-daemon` and `traits.determinate` conflict";
          }
        ];

        launchd.daemons = {
          determinate-nixd-store.serviceConfig = {
            Label = "systems.determinate.nix-store";
            RunAtLoad = true;

            StandardErrorPath = lib.mkForce "/var/log/determinate-nix-init.log";
            StandardOutPath = lib.mkForce "/var/log/determinate-nix-init.log";

            ProgramArguments = lib.mkForce [
              "/usr/local/bin/determinate-nixd"
              "--nix-bin"
              "${config.nix.package}/bin"
              "init"
            ];
          };

          determinate-nixd.serviceConfig = {
            Label = "systems.determinate.nix-daemon";

            StandardErrorPath = lib.mkForce "/var/log/determinate-nix-daemon.log";
            StandardOutPath = lib.mkForce "/var/log/determinate-nix-daemon.log";

            ProgramArguments = lib.mkForce [
              "/usr/local/bin/determinate-nixd"
              "--nix-bin"
              "${config.nix.package}/bin"
              "daemon"
            ];

            Sockets = {
              "determinate-nixd.socket" = {
                # We'd set `SockFamily = "Unix";`, but nix-darwin automatically sets it with SockPathName
                SockPassive = true;
                SockPathName = "/var/run/determinate-nixd.socket";
              };

              "nix-daemon.socket" = {
                # We'd set `SockFamily = "Unix";`, but nix-darwin automatically sets it with SockPathName
                SockPassive = true;
                SockPathName = "/var/run/nix-daemon.socket";
              };
            };

            SoftResourceLimits = {
              NumberOfFiles = lib.mkDefault 1048576;
              NumberOfProcesses = lib.mkDefault 1048576;
              Stack = lib.mkDefault 67108864;
            };

            HardResourceLimits = {
              NumberOfFiles = lib.mkDefault 1048576;
              NumberOfProcesses = lib.mkDefault 1048576;
              Stack = lib.mkDefault 67108864;
            };
          };
        };

        nix.useDaemon = true;

        services.nix-daemon.enable = false;

        system.activationScripts = {
          launchd.text = lib.mkBefore ''
            if test -e /Library/LaunchDaemons/org.nixos.nix-daemon.plist; then
              echo "Unloading org.nixos.nix-daemon"
              launchctl bootout system /Library/LaunchDaemons/org.nixos.nix-daemon.plist || true
              mv /Library/LaunchDaemons/org.nixos.nix-daemon.plist /Library/LaunchDaemons/.before-determinate-nixd.org.nixos.nix-daemon.plist.skip
            fi

            if test -e /Library/LaunchDaemons/org.nixos.darwin-store.plist; then
              echo "Unloading org.nixos.darwin-store"
              launchctl bootout system /Library/LaunchDaemons/org.nixos.darwin-store.plist || true
              mv /Library/LaunchDaemons/org.nixos.darwin-store.plist /Library/LaunchDaemons/.before-determinate-nixd.org.nixos.darwin-store.plist.skip
            fi

            install -d -m 755 -o root -g wheel /usr/local/bin
            cp ${lib.getExe package "determinate-nixd"} /usr/local/bin/.determinate-nixd.next
            chmod +x /usr/local/bin/.determinate-nixd.next
            mv /usr/local/bin/.determinate-nixd.next /usr/local/bin/determinate-nixd
          '';

          nix-daemon = lib.mkForce {
            enable = false;
            text = "";
          };
        };
      })
    ]
  );
}
