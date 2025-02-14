{ lib, ... }:

# Much of this is sourced from https://xeiaso.net/blog/paranoid-nixos-2021-07-18/
{
  security = {
    apparmor.enable = lib.mkDefault true;
    audit.enable = lib.mkDefault true;
    auditd.enable = lib.mkDefault true;

    pam.services = {
      # Fix `run0`
      # TODO: Upstream?
      systemd-run0 = {
        startSession = true;
        setEnvironment = true;
      };
    };

    polkit.enable = true;

    sudo.enable = false;
  };

  services.dbus.apparmor = lib.mkDefault "enabled";
}
