{
	config,
	pkgs,
	...
}: let
	xserverConfig =
		if config.sys.desktop == "plasma"
		then {
			displayManager.sddm.enable = true;
			desktopManager.plasma5 = {
				enable = true;
				excludePackages = with pkgs.libsForQt5; [
					khelpcenter
					plasma-browser-integration
					print-manager
				];
			};
		}
		else {};
in {
	services.xserver = xserverConfig;
}
