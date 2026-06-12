alias r := rebuild
alias rr := remote-rebuild
alias u := update
alias c := check-all

flake := justfile_directory()
rebuild := if os() == "macos" { "darwin-rebuild" } else { "nixos-rebuild" }

# Switch to the latest system configuration
default: rebuild

# Re-configure a system configuration
rebuild +args="switch":
    {{ rebuild }} \
      --accept-flake-config \
      --sudo \
      --flake '{{ flake }}' \
      {{ args }}

# Re-configure a remote system configuration
remote-rebuild system *args:
    {{ rebuild }} \
      --build-host 'root@{{ system }}' \
      --target-host 'root@{{ system }}' \
      --no-reexec \
      --use-substitutes \
      --flake '{{ flake }}#{{ system }}' \
      {{ args }}

# Evaluate the current flake for all systems
check-all *args:
    nix flake check \
      --all-systems \
      --no-build \
      '{{ flake }}' \
      {{ args }}

# Update the given flake inputs, or all
update *inputs:
    nix flake update {{ inputs }} \
      --commit-lock-file \
      --commit-lockfile-summary "flake: update {{ if inputs == "" { "all inputs" } else { replace(inputs, " ", ", ") } }}" \
      --flake '{{ flake }}'
