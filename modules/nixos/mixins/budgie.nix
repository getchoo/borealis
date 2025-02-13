{
  config,
  lib,
  pkgs,
  ...
}:

# TODO: Improve this
{
  config = lib.mkMerge [
    {
      environment = {
        budgie.excludePackages = with pkgs; [
          qogir-theme
          qogir-icon-theme

          # I don't like MATE's apps. Fedora doesn't use them either :/
          mate.atril
          mate.pluma
          mate.engrampa
          mate.mate-calc
          mate.mate-terminal
          mate.mate-system-monitor
          vlc
        ];
      };

      services.xserver.desktopManager.budgie = {
        # Make sure we actually use the themes below
        extraGSettingsOverrides = ''
          [org.gnome.desktop.interface:Budgie]
          color-scheme='prefer-dark'
          gtk-theme='Materia-dark'
          icon-theme='Papirus-Dark'
        '';
      };
    }

    (lib.mkIf config.services.xserver.desktopManager.budgie.enable {
      environment.systemPackages = with pkgs; [
        materia-theme
        papirus-icon-theme

        # Replacements for MATE apps
        celluloid
        cinnamon.nemo-fileroller
        evince
        gedit
        gnome-console
        gnome.gnome-calculator
        gnome.gnome-system-monitor
      ];

      services.xserver.displayManager.lightdm = {
        enable = lib.mkDefault true;

        # Fedora uses these by default
        greeters.slick = {
          theme = {
            name = "Materia-dark";
            package = pkgs.materia-theme;
          };
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
        };
      };
    })
  ];
}
