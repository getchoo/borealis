{
  config,
  lib,
  secretsDir,
  ...
}:

let
  cfg = config.borealis.remote-builders;
in

{
  options.borealis.remote-builders = {
    enable = lib.mkEnableOption "the use of remote builders";

    manageSecrets = lib.mkEnableOption "automatic management of SSH keys for builders" // {
      default = true;
    };

    builders = {
      atlas = lib.mkEnableOption "`atlas` as a remote builder";
      macstadium = lib.mkEnableOption "`macstadium` as a remote builder";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        nix = {
          distributedBuilds = true;

          settings = {
            builders-use-substitutes = true;
          };
        };
      }

      (lib.mkIf cfg.builders.atlas {
        nix.buildMachines = [
          {
            hostName = "atlas";
            maxJobs = 4;
            publicHostKey = "IyBhdGxhczoyMiBTU0gtMi4wLVRhaWxzY2FsZQphdGxhcyBzc2gtZWQyNTUxOSBBQUFBQzNOemFDMWxaREkxTlRFNUFBQUFJQzdZaVNZWXgvK3ptVk9QU0NFUkh6U3NNZVVRdEErVnQxVzBzTFV3NFloSwo=";
            sshUser = "atlas";
            supportedFeatures = [
              "benchmark"
              "big-parallel"
              "gccarch-armv8-a"
              "kvm"
              "nixos-test"
            ];
            systems = [
              "aarch64-linux"
            ];
          }
        ];
      })

      (lib.mkIf cfg.builders.macstadium {
        nix.buildMachines = [
          (lib.mkMerge [
            {
              hostName = "mini.scrumplex.net";
              maxJobs = 8;
              publicHostKey = "IyBtaW5pLnNjcnVtcGxleC5uZXQ6MjIgU1NILTIuMC1PcGVuU1NIXzkuOAptaW5pLnNjcnVtcGxleC5uZXQgc3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU9DV1lXL29TbW5GYU1sOGQ0eHNjaGhxNkNKZkdjQ1M4djhLYkErb0dmQ3IK";
              sshUser = "bob-the-builder";
              supportedFeatures = [
                "nixos-test"
                "benchmark"
                "big-parallel"
                "apple-virt"
              ];
              systems = [
                "aarch64-darwin"
                "x86_64-darwin"
              ];
            }

            (lib.mkIf cfg.manageSecrets {
              sshKey = config.age.secrets.macstadium.path;
            })
          ])
        ];
      })

      (lib.mkIf (cfg.manageSecrets && cfg.builders.macstadium) {
        age.secrets = {
          macstadium = {
            file = secretsDir + "/macstadium.age";
            mode = "600";
          };
        };
      })
    ]
  );
}
