# shellcheck shell=bash
set -euxo pipefail
declare prev_config new_config

prev_config="$(readlink -f /run/current-system)"
readonly prev_config

new_config="$(nixos-rebuild --refresh "$@" dry-build 2>&1 | grep nixos-system | tr -d ' ')"
readonly new_config

if [ "$prev_config" = "$new_config" ]; then
	echo "No upgrade needed!"
	exit 0
fi

# If it's not a known "bad" configuration, rebuild
if ! grep "$new_config" "$STATE_FILE" &>/dev/null; then
	nixos-rebuild "$@" "$REBUILD_OPERATION"
fi
