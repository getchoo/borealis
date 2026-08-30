#!/bin/sh
set -eu

name="$(basename "$0")"
directory="$(readlink -f "$0" | xargs dirname)"
readonly name directory

readonly usage="usage:
	$name <subcommand> [arguments...]

subcommands:
	check-all, c            check (not build) all outputs
	rebuild, r		wrapper for nixos-rebuild
	remote-rebuild, rr      wrapper for nixos-rebuild against a given host
	update, u               update flake input(s)
"

bail() {
	echo "error: $*" >&2
	exit 1
}

log_cmd() {
	(
		set -x
		"$@"
	)
}

check_all() {
	log_cmd nix flake check \
		--accept-flake-config \
		--all-systems \
		--no-build \
		"$directory" \
		"$@"
}

rebuild() {
	log_cmd nixos-rebuild \
		--accept-flake-config \
		--flake "$directory" \
		--no-reexec \
		--sudo \
		"$@"
}

remote_rebuild() {
	system="$1"
	[ -z "$system" ] && bail "remote-rebuild requires a \`system\` keyword argument"
	shift
	host="root@$system"

	rebuild \
		--build-host "$host" \
		--target-host "$host" \
		--use-substitutes \
		--flake "$directory#$system" \
		"$@"
}

update() {
	if [ $# -lt 1 ]; then
		inputs="all inputs"
	else
		inputs="$(printf '%s, ' "$@")"
		inputs="${inputs%, }"
	fi

	log_cmd nix flake update "$@" \
		--flake "$directory" \
		--commit-lock-file \
		--commit-lockfile-summary "flake: update $inputs"
}

case "${1:-}" in
c | check-all)
	subcommand=check_all
	shift
	;;
r | rebuild)
	subcommand=rebuild
	shift
	;;
rr | remote-rebuild)
	subcommand=remote_rebuild
	shift
	;;
u | update)
	subcommand=update
	shift
	;;
h | help)
	echo "$usage"
	exit 0
	;;
*)
	subcommand=rebuild
	;;
esac
"$subcommand" "$@"
