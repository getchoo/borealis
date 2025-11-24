{
  config,
  inputs,
  secretsDir,
  ...
}:
{
  imports = [ inputs.nixpkgs-tracker-bot.nixosModules.default ];

  age.secrets.nixpkgs-tracker-bot.file = secretsDir + "/nixpkgs-tracker-bot.age";

  services.nixpkgs-tracker-bot = {
    enable = false;
    environmentFile = config.age.secrets.nixpkgs-tracker-bot.path;
  };
}
