#!/usr/bin/env bash
set -euo pipefail

help() {
	echo "Mirror a GitHub user's repositories

Usage: $(basename "$0") [options] <user>...

Options:
  -h --help                         Show this screen
  -d --directory DIRECTORY          Where to clone repositories (defaults to ./git)"
}

create_if_not_exists() {
	if [ ! -d "$1" ]; then
		mkdir -p "$1"
	fi
}

repo_endpoint() {
	echo "https://api.github.com/users/$1/repos"
}

users=()
output_directory="git"

while [ "$#" -gt 0 ]; do
	case $1 in
	-h | --help)
		help
		exit 0
		;;
	-d | --directory)
		output_directory="$2"
		shift
		shift
		;;
	-*)
		echo "error: unknown option $1"
		help
		exit 1
		;;
	*)
		users+=("$1")
		shift
		;;
	esac
done

if [ "${#users[@]}" -lt 1 ]; then
	echo "error: at least one user must be specified"
	help
	exit 1
fi

create_if_not_exists "$output_directory"
cd "$output_directory"

for user in "${users[@]}"; do
	create_if_not_exists "$user"

	url="$(repo_endpoint "$user")"
	curl --fail --location --show-error --silent "$url" | jq --raw-output '.[].name' | while read -r repo; do
		repo_path="$user"/"$repo"

		if [ -d "$repo_path" ]; then
			pushd "$repo_path" &>/dev/null
			echo "Pulling $repo_path..."
			if ! git remote update --prune &>/dev/null; then
				echo "Unable to pull $repo_path! Continuing..."
			fi
			popd &>/dev/null
		else
			echo "Cloning $repo_path..."
			git clone --bare --mirror https://github.com/"$repo_path".git "$repo_path" &>/dev/null
		fi
	done
done
