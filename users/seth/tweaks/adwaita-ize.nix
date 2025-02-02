{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.seth.tweaks.adwaita-ize;
in
{
  options.seth.tweaks.adwaita-ize = {
    enable = lib.mkEnableOption "libadwaita themeing for non-libadwaita apps";

    adw-gtk3 = lib.mkEnableOption "adw-gtk3 theme for GTK3 apps" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.adw-gtk3 {
        assertions = [
          {
            assertion = config.gtk.enable;
            message = "`gtk.enable` must be `true` to apply the adw-gtk3 theme";
          }
        ];

        gtk.theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
      })
    ]
  );
}
