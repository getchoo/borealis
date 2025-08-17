alias r := rebuild
alias rr := remote-rebuild
alias e := eval
alias ea := eval-all
alias u := update
alias ui := update-input

rebuild := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild-ng" }

default:
    @just --choose

rebuild subcmd *args="":
    {{ rebuild }} \
      {{ subcmd }} \
      --accept-flake-config \
      --sudo \
      --flake 'git+file://{{ justfile_directory() }}' \
      {{ args }}

remote-rebuild system subcmd *args="":
    {{ rebuild }} \
      {{ subcmd }} \
      --build-host 'root@{{ system }}' \
      --target-host 'root@{{ system }}' \
      --no-reexec \
      --use-substitutes \
      --flake 'git+file://{{ justfile_directory() }}#{{ system }}' \
      {{ args }}

eval system *args="":
    nix eval \
      --no-allow-import-from-derivation \
      'git+file://{{ justfile_directory() }}#nixosConfigurations.{{ system }}.config.system.build.toplevel' \
      {{ args }}

eval-all *args="":
    nix flake check \
      --all-systems \
      --no-build \
      'git+file://{{ justfile_directory() }}' \
      {{ args }}

update:
    nix flake update \
      --commit-lock-file \
      --commit-lockfile-summary "flake: update all inputs" \
      --flake 'git+file://{{ justfile_directory() }}'

update-input input:
    nix flake update {{ input }} \
      --commit-lock-file \
      --commit-lockfile-summary "flake: update {{ input }}" \
      --flake 'git+file://{{ justfile_directory() }}'
