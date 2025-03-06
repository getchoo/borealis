# NOTE: Unused
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
        environment = {
          # `determinate-nixd` overrides /etc/nix/nix.conf with it's own
          etc."nix/nix.custom.conf" = { inherit (config.environment.etc."nix/nix.conf") source; };

          systemPackages = [
            package
          ];
        };

        systemd = {
          services.nix-daemon.serviceConfig = {
            ExecStart = [
              ""
              "@${lib.getExe' package "determinate-nixd"} determinate-nixd --nix-bin ${config.nix.package}/bin daemon"
            ];
            KillMode = lib.mkDefault "process";
            LimitNOFILE = lib.mkDefault 1048576;
            LimitSTACK = lib.mkDefault "64M";
            TasksMax = lib.mkDefault 1048576;
          };

          sockets = {
            determinate-nixd = {
              description = "Determinate Nixd Daemon Socket";
              wantedBy = [ "sockets.target" ];
              before = [ "multi-user.target" ];

              unitConfig = {
                RequiresMountsFor = [
                  "/nix/store"
                  "/nix/var/determinate"
                ];
              };

              socketConfig = {
                Service = "nix-daemon.service";
                FileDescriptorName = "determinate-nixd.socket";
                ListenStream = "/nix/var/determinate/determinate-nixd.socket";
                DirectoryMode = "0755";
              };
            };

            nix-daemon.socketConfig = {
              FileDescriptorName = "nix-daemon.socket";
            };
          };
        };
      })
    ]
  );
}
