{
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.arkenfox.hmModules.arkenfox ];

  programs.firefox = {
    arkenfox = {
      enable = true;
      version = "128.0";
    };

    profiles.arkenfox.arkenfox =
      let
        enableSections =
          sections:
          lib.genAttrs sections (_: {
            enable = true;
          });
      in
      lib.recursiveUpdate
        {
          enable = true;

          # enable safe browsing
          "0400"."0403"."browser.safebrowsing.downloads.remote.enabled".value = true;

          # fix hulu
          "1200"."1201"."security.ssl.require_safe_negotiation".value = false;

          "2600"."2651"."browser.download.useDownloadDir" = {
            enable = true;
            value = true;
          };

          # disable rfp letterboxing
          "4500"."4504"."privacy.resistFingerprinting.letterboxing".value = false;

          "5000" = {
            "5003"."signon.rememberSignons".enable = true;
            # enable search autocomplete
            "5021"."keyword.enabled".value = true;
          };
        }
        (enableSections [
          "0100"
          "0200"
          "0300"
          "0400"
          "0600"
          "0700"
          "0800"
          "0900"
          "1000"
          "1200"
          "1600"
          "1700"
          "2000"
          "2400"
          "2600"
          "2700"
          "2800"
          "4500"
        ]);
  };
}
