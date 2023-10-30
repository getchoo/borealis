{config, ...}: {
  programs.mangohud = {
    inherit (config.desktop) enable;
    settings = {
      legacy_layout = false;
      cpu_stats = true;
      cpu_temp = true;
      gpu_stats = true;
      gpu_temp = true;
      fps = true;
      frametime = true;
      media_player = true;
      media_player_name = "spotify";
    };
  };
}
