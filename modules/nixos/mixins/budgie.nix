{
  config,
  lib,
  pkgs,
  ...
}:

# Main point here is to make it more akin to the Budgie spin of Fedora
{
  config = lib.mkMerge [
    {
      environment = {
        budgie.excludePackages = with pkgs; [
          # I don't like MATE's apps. Fedora doesn't use them either :/
          atril
          engrampa
          eom
          gnome-terminal
          mate-calc
          mate-system-monitor
          mate-terminal
          pluma
          vlc
        ];
      };

      services.desktopManager.budgie = {
        # Make sure we actually use the themes below
        extraGSettingsOverrides = ''
          [org.gnome.desktop.interface:Budgie]
          color-scheme='prefer-dark'
          gtk-theme='Materia-dark'
          icon-theme='Papirus-Dark'
        '';
      };
    }

    (lib.mkIf config.services.desktopManager.budgie.enable {
      environment.systemPackages = with pkgs; [
        materia-theme
        papirus-icon-theme

        # Replacements for MATE apps
        # TODO: Find system monitor
        ghostty
        haruna
        kdePackages.ark
        kdePackages.dolphin
        kdePackages.gwenview
        kdePackages.kate
        kdePackages.kcalc
        kdePackages.okular
      ];

      services.displayManager = {
        plasma-login-manager.enable = lib.mkDefault true;
      };
    })
  ];
}
