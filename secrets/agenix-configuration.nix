{ config, lib, ... }:

let
  toAgeRegex = directory: "^${directory}\/.*\.age$";

  secretsForSystemRecipient = hostname: pubkey: {
    regex = toAgeRegex hostname;
    recipients = {
      ${hostname} = pubkey;
    };
  };
in

{
  rootDirectory = ./.;

  recipients = {
    # Catch-all
    default = [ config.recipients.getchoo ];

    # Users
    getchoo = "age1zyqu6zkvl0rmlejhm5auzmtflfy4pa0fzwm0nzy737fqrymr7crsqrvnhs";

    # Systems
    atlas = "age18eu3ya4ucd2yzdrpkpg7wrymrxewt8j3zj2p2rqgcjeruacp0dgqryp39z";
    glados = "age1n7tyxx63wpgnmwkzn7dmkm62jxel840rk3ye3vsultrszsfrwuzsawdzhq";
    glados-wsl = "age1ffqfq3azqfwxwtxnfuzzs0y566a7ydgxce4sqxjqzw8yexc2v4yqfr55vr";
  };

  secrets = [
    {
      regex = toAgeRegex "personal";
      recipients = { inherit (config.recipients) glados glados-wsl; };
    }
  ]
  # Map system recipients to secrets in their subdirectory (i.e., `atlas` imports `atlas/*.age`)
  ++ lib.mapAttrsToList secretsForSystemRecipient { inherit (config.recipients) atlas; };
}
