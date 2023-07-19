_: prev: let
  mkOverride = d: let
    d' = d.override {withOpenASAR = true;};
    inherit (d') pname;

    desktopName =
      if pname == "discord-canary"
      then "Discord Canary"
      else "Discord";

    flags = "--enable-gpu-rasterization --enable-zero-copy --enable-gpu-compositing --enable-native-gpu-memory-buffers --enable-oop-rasterization --enable-features=UseSkiaRenderer,WaylandWindowDecorations";
    desktopItem = prev.makeDesktopItem {
      name = pname;
      exec = "${builtins.replaceStrings [" "] [""] desktopName} ${flags}";
      icon = pname;
      inherit desktopName;
      genericName = d'.meta.description;
      categories = ["Network" "InstantMessaging"];
      mimeTypes = ["x-scheme-handler/discord"];
    };
  in
    d'.overrideAttrs (_: {inherit desktopItem;});
in {
  discord = mkOverride prev.discord;
  discord-canary = mkOverride prev.discord-canary;
}
