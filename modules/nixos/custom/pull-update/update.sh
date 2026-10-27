# shellcheck shell=bash
set -euxo pipefail
declare prev_config new_config

prev_config="$(readlink -f /run/current-system)"
readonly prev_config

# FIXME: Why doesn't `nix repl` support NO_COLOR?? grrrr
# Thanks to https://stackoverflow.com/questions/17998978/removing-colors-from-output/51141872#51141872 for ANSI color escape
new_config="$(echo 'config.system.build.toplevel.outPath' | nixos-rebuild --refresh "$@" repl | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | tr -d '"')"
readonly new_config

if [ "$prev_config" = "$new_config" ]; then
	echo "No upgrade needed!"
	exit 0
fi

# If it's not a known "bad" configuration, rebuild
if ! grep "$new_config" "$STATE_FILE" &>/dev/null; then
	nixos-rebuild "$@" "$REBUILD_OPERATION"
fi
