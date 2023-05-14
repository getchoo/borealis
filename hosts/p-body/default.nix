{
  config,
  guzzle_api,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-image.nix")
    ./nginx.nix
  ];

  _module.args.nixinate = {
    host = "167.99.145.73";
    sshUser = "root";
    buildOn = "remote";
    substituteOnTarget = true;
    hermetic = false;
  };

  networking = {
    domain = "mydadleft.me";
    hostName = "p-body";
  };

  services = {
    guzzle-api = {
      enable = true;
      url = "https://" + config.networking.domain + "/api";
      port = "8080";
      package = guzzle_api.packages.x86_64-linux.guzzle-api-server;
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
    }
  ];

  system.stateVersion = "22.11";

  users.users = let
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOeEbjzzzwf9Qyl0JorokhraNYG4M2hovyAAaA6jPpM7 seth@glados"
    ];
  in {
    root = {inherit openssh;};
    p-body = {
      extraGroups = ["wheel"];
      isNormalUser = true;
      shell = pkgs.bash;
      passwordFile = config.age.secrets.userPassword.path;
      inherit openssh;
    };
  };

  zramSwap.enable = true;
}
