(import ./eval-agenix.nix {
  modules = [ ./agenix-configuration.nix ];
}).config.build.rules
