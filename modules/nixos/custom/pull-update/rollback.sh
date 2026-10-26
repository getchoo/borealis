# shellcheck shell=bash
set -euxo pipefail

bad_config="$(readlink -f /run/current-system)"
nixos-rebuild "$REBUILD_OPERATION" --rollback

# Mark the configuration we just rolled back from as bad
echo "$bad_config" >>"$STATE_FILE"
# Cleanup old "bad" configurations we're unlikely to come across again
tail -n 10 "$STATE_FILE" | sponge "$STATE_FILE"
