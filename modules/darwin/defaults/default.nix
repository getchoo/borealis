{
  imports = [
    ./desktop-programs.nix
    ./programs.nix
  ];

  services.nix-daemon.enable = true;
}
