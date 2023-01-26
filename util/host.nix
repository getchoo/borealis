{nixpkgs, home-manager, ...}:

{
	mkHost = {
		name,
		modules,
		system ? "x86_64-linux",
		pkgs,
	}:
		pkgs.lib.nixosSystem {
			inherit system;
			modules =
				[
					../hosts/common

					{
						networking.hostName = nixpkgs.lib.mkDefault name;
					}

					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
					}
				]
				++ modules;
		};
}
