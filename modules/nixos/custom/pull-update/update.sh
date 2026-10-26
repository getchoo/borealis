# shellcheck shell=bash
set -euxo pipefail
declare prev_config new_config

prev_config="$(readlink -f /run/current-system)"
readonly prev_config

new_config="$(echo 'config.system.build.toplevel.outPath' | nixos-rebuild --refresh "$@" repl | tr -d '"')"
readonly new_config

if [ "$prev_config" != "$new_config" ]; then
	nixos-rebuild "$@" "$REBUILD_OPERATION"
else
	echo "No upgrade needed!"
fi
