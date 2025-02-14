{
  services.spotifyd = {
    settings = {
      # Implicitly use zeroconf
      global = {
        autoplay = true;
        backend = "pulseaudio";
        bitrate = 320;
      };
    };
  };
}
