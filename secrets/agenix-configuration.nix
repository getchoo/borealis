{ config, lib, ... }:

{
  rootDirectory = ./.;

  recipients = {
    # Catch-all
    default = [ config.recipients.getchoo ];

    # Users
    getchoo = "age1zyqu6zkvl0rmlejhm5auzmtflfy4pa0fzwm0nzy737fqrymr7crsqrvnhs";

    # Machines
    atlas = "age18eu3ya4ucd2yzdrpkpg7wrymrxewt8j3zj2p2rqgcjeruacp0dgqryp39z";
    glados = "age1n7tyxx63wpgnmwkzn7dmkm62jxel840rk3ye3vsultrszsfrwuzsawdzhq";
    glados-wsl = "age1ffqfq3azqfwxwtxnfuzzs0y566a7ydgxce4sqxjqzw8yexc2v4yqfr55vr";
  };

  secrets = lib.mapAttrsToList (hostname: pubkey: {
    regex = "^${hostname}\/.*\.age$";
    recipients = {
      ${hostname} = pubkey;
    };
  }) { inherit (config.recipients) atlas glados glados-wsl; };
}
