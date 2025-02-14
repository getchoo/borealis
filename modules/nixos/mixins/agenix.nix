{ inputs, ... }:

{
  imports = [ inputs.agenix.nixosModules.default ];

  config = {
    age = {
      identityPaths = [ "/etc/age/key" ];
    };
  };
}
