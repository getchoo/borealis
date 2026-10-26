# shellcheck shell=bash
declare prev_config new_config

prev_config="$(readlink -f /run/current-system)"
readonly prev_config

new_config="$(echo 'config.system.build.toplevel.outPath' | nixos-rebuild repl --refresh "$@" | tr -d '"')"
readonly new_config

if [ "$prev_config" != "$new_config" ]; then
	nixos-rebuild "$@"
else
	echo "No upgrade needed!"
fi
