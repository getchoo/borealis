{
  configurations = {
    nixos = {
      glados = {
        modules = [ ./glados ];
      };

      glados-wsl = {
        modules = [ ./glados-wsl ];
      };

      atlas = {
        modules = [ ./atlas ];
      };
    };
  };
}
