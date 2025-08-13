{
  config,
  lib,
  pkgs,
  ...
}:

{
  users = {
    defaultUserShell = pkgs.bash;
    mutableUsers = false;

    users.root = {
      home = lib.mkDefault "/root";
      uid = config.ids.uids.root;
      group = "root";
    };
  };
}
