{
  config,
  lib,
  secretsDir,
  ...
}:
let
  cfg = config.traits.mac-builder;
in
{
  options.traits.mac-builder = {
    enable = lib.mkEnableOption "macOS remote builders";
    manageSecrets = lib.mkEnableOption "managing SSH keys for builders" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        nix = {
          buildMachines = [
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

          distributedBuilds = true;

          settings = {
            builders-use-substitutes = true;
          };
        };
      }

      (lib.mkIf cfg.manageSecrets {
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
