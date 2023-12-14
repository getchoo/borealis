{
  config,
  pkgs,
  secretsDir,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./attic.nix
    ./miniflux.nix
    ./nginx.nix
  ];

  age.secrets.teawiebot.file = secretsDir + "/teawieBot.age";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    domain = "mydadleft.me";
    hostName = "atlas";
    networkmanager.enable = false;
  };

  services = {
    resolved.enable = false;
    teawiebot = {
      enable = true;
      environmentFile = config.age.secrets.teawiebot.path;
    };
  };

  users.users.atlas = {
    isNormalUser = true;
    shell = pkgs.bash;
    hashedPasswordFile = config.age.secrets.userPassword.path;
  };

  zramSwap.enable = true;
}
