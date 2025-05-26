{
  config,
  lib,
  ...
}:

let
  cfg = config.services.tailscale;
in

{
  config = lib.mkMerge [
    {
      services.tailscale = {
        openFirewall = true;
      };
    }

    (lib.mkIf cfg.enable {
      networking.firewall = {
        # Trust all connections over Tailscale
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
      };
    })
  ];
}
