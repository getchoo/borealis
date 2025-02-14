{ inputs, ... }:
let
  inherit (inputs) self;
in
{
  imports = [
    ./nix.nix
  ];

  system.configurationRevision = self.rev or self.dirtyRev or "dirty-unknown";

  time.timeZone = "America/New_York";
}
