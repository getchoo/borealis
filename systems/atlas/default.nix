{
  config,
  modulesPath,
  inputs,
  secretsDir,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./hardware-configuration.nix
    ./kanidm.nix
    ./moyai.nix
    ./nixpkgs-tracker-bot.nix

    inputs.self.nixosModules.default
  ];

  borealis = {
    github-mirror = {
      enable = true;

      hostname = "git." + config.networking.domain;
      mirroredUsers = [
        "getchoo"
        "getchoo-archive"
      ];
    };

    profiles.server.enable = true;

    rime = {
      enable = true;

      domain = "rime." + config.networking.domain;
      nginx = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  age.secrets = {
    miniflux.file = secretsDir + "/miniflux.age";
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    domain = "getchoo.com";
    hostName = "atlas";

    firewall.allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
    ];
  };

  nixpkgs.hostPlatform = "aarch64-linux";

  services = {
    hedgedoc = {
      enable = true;

      settings = {
        domain = "hedgedoc." + config.networking.domain;
      };
    };

    miniflux = {
      enable = true;

      adminCredentialsFile = config.age.secrets.miniflux.path;
      config = {
        BASE_URL = "https://miniflux.${config.networking.domain}";
      };
    };

    nginx.enable = true;
  };

  system.stateVersion = "23.05";
}
