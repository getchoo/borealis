{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.seth.adw-gtk3;
in

{
  options.seth.adw-gtk3 = {
    enable = lib.mkEnableOption "the use of the `adw-gtk3` GTK theme";

    mode = lib.mkOption {
      type = lib.types.enum [
        "light"
        "dark"
      ];
      default = "dark";
      description = "Mode of the adw-gtk3 theme";
      example = "light";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.gtk.enable;
        message = "`gtk.enable` must be `true` to apply the adw-gtk3 theme";
      }
    ];

    gtk = {
      enable = true;

      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
    };
  };
}
