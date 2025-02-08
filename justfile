alias b := build
alias c := check
alias sw := switch
alias t := test
alias u := update
alias ui := update-input

rebuild := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild" }

default:
    @just --choose

[private]
rebuild subcmd *extraArgs="":
    {{ rebuild }} \
      {{ subcmd }} \
      {{ extraArgs }} \
      --print-build-logs \
      --flake .

remote-rebuild system subcmd *extraArgs="":
    {{ rebuild }} \
      {{ subcmd }} \
      --build-host root@{{ system }} \
      --target-host root@{{ system }} \
      --fast \
      --use-substitutes \
      {{ extraArgs }} \
      --flake '.#{{ system }}'

boot *extraArgs="": (rebuild "boot" extraArgs)

build *extraArgs="": (rebuild "build" extraArgs)

switch *extraArgs="": (rebuild "switch" extraArgs)

test *extraArgs="": (rebuild "test" extraArgs)

check *args="":
    nix flake check \
      --print-build-logs \
      --show-trace \
      --accept-flake-config \
      --no-allow-import-from-derivation \
      {{ args }}

eval system *args="":
    nix eval \
      --raw \
      '.#nixosConfigurations.{{ system }}.config.system.build.toplevel' \
      --no-allow-import-from-derivation \
      {{ args }}

update:
    nix flake update \
      --commit-lock-file \
      --commit-lockfile-summary "flake: update all inputs"

update-input input:
    nix flake update {{ input }} \
      --commit-lock-file \
      --commit-lockfile-summary "flake: update {{ input }}"

deploy system:
    @just remote-rebuild {{ system }} "switch"
