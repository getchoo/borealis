{
  config,
  secretsDir,
  inputs,
  ...
}:
{
  imports = [ inputs.moyai-bot.nixosModules.default ];

  age.secrets.moyai-bot.file = secretsDir + "/teawieBot.age";

  services.moyai-discord-bot = {
    enable = true;
    environmentFile = config.age.secrets.moyai-bot.path;
  };
}
