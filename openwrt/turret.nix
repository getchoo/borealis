{
  openwrtPackages,
  runCommand,
}:

openwrtPackages.buildOpenWrtImage {
  release = "23.05.0";
  profile = "netgear_wac104";

  files = runCommand "image-files" { } ''
    mkdir -p $out/etc/uci-defaults

    cat > $out/etc/uci-defaults/99-custom << EOF
    uci -q batch << EOI
    set system.@system[0].hostname="turret"
    del_list network.@device[0].ports="lan4"
    set network.wan="interface"
    set network.wan.device="lan4"
    set network.wan.proto="dhcp"
    set wireless.default_radio0.ssid="Box-2.4G"
    set wireless.default_radio0.encryption="psk2"
    set wireless.default_radio0.key="CorrectHorseBatteryStaple"
    set wireless.default_radio1.ssid="Box-5G"
    set wireless.default_radio1.encryption="psk2"
    set wireless.default_radio1.key="CorrectHorseBatteryStaple"
    add_list dhcp.@dnsmasq[0].server="1.1.1.1"
    add_list dhcp.@dnsmasq[0].server="1.0.0.1"
    commit
    EOI
    EOF
  '';
}
