{ lib, inputs, ... }:

let
  inherit (inputs) self;
in

{
  imports = [
    ./custom
    ./mixins
    ./sanity-checks.nix
    ./users
  ];

  system.configurationRevision = self.rev or self.dirtyRev or "dirty-unknown";

  # TODO: Maybe don't set this globally?
  time.timeZone = lib.mkDefault "America/New_York";
}
