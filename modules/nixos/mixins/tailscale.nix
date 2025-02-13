{
  config,
  lib,
  ...
}:

let
  cfg = config.services.tailscale;

  usingTailscaleSSH = lib.elem "--ssh" config.services.tailscale.extraUpFlags;
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

    (lib.mkIf (cfg.enable && usingTailscaleSSH) {
      networking.firewall = {
        allowedTCPPorts = [ 22 ];
      };
    })
  ];
}
