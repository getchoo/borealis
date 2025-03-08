alias r := rebuild
alias rr := remote-rebuild
alias e := eval
alias ea := eval-all
alias u := update
alias ui := update-input

rebuild := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild" }

default:
    @just --choose

rebuild subcmd *args="":
    {{ rebuild }} \
      {{ subcmd }} \
      --use-remote-sudo \
      --flake {{ justfile_directory() }} \
      {{ args }}

remote-rebuild system subcmd *args="":
    {{ rebuild }} \
      {{ subcmd }} \
      --build-host 'root@{{ system }}' \
      --target-host 'root@{{ system }}' \
      --no-build-nix \
      --use-substitutes \
      --flake '{{ justfile_directory() }}#{{ system }}' \
      {{ args }}

eval system *args="":
    nix eval \
      --no-allow-import-from-derivation \
      '{{ justfile_directory() }}#nixosConfigurations.{{ system }}.config.system.build.toplevel' \
      {{ args }}

eval-all *args="":
    nix flake check --all-systems --no-build {{ justfile_directory() }} {{ args }}

update:
    nix flake update \
      --commit-lock-file \
      --commit-lockfile-summary "flake: update all inputs" \
      --flake {{ justfile_directory() }}

update-input input:
    nix flake update {{ input }} \
      --commit-lock-file \
      --commit-lockfile-summary "flake: update {{ input }}" \
      --flake {{ justfile_directory() }}
