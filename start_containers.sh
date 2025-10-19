#!/usr/bin/env bash
set -euo pipefail

# start_containers.sh
# Loop through a list of folders and run `docker compose up -d` in each.
#
# Edit the FOLDERS array below to add/remove directories.

### Configuration: add absolute paths to your folders here
FOLDERS=(
  "/path-to-folder"
  "/path-to-anohter-folder"
)


# Optional: path to docker compose binary. If empty, script will try to find one.
DOCKER_COMPOSE_CMD=""

# Timeout for waiting for docker to be available (seconds)
DOCKER_WAIT_TIMEOUT=15

log() { printf "%s\n" "$*"; }
err() { printf "ERROR: %s\n" "$*" >&2; }

find_docker_compose() {
  if [[ -n "${DOCKER_COMPOSE_CMD:-}" ]]; then
    echo "$DOCKER_COMPOSE_CMD"
    return 0
  fi

  # Prefer docker compose (v2 plugin) if available
  if command -v docker >/dev/null 2>&1; then
    if docker compose version >/dev/null 2>&1; then
      echo "docker compose"
      return 0
    fi
  fi

  # Fallback to docker-compose (v1 standalone)
  if command -v docker-compose >/dev/null 2>&1; then
    echo "docker-compose"
    return 0
  fi

  return 1
}

wait_for_docker() {
  local waited=0
  while ! docker info >/dev/null 2>&1; do
    if (( waited >= DOCKER_WAIT_TIMEOUT )); then
      return 1
    fi
    sleep 1
    ((waited++))
  done
  return 0
}

main() {
  if ! dc_cmd=$(find_docker_compose); then
    err "No docker compose command found. Install Docker and/or docker-compose."
    exit 2
  fi

  log "Using compose command: $dc_cmd"

  if ! wait_for_docker; then
    err "Docker daemon does not appear to be running or reachable."
    exit 3
  fi

  local failures=0

  for dir in "${FOLDERS[@]}"; do
    log "\n=== Processing: $dir ==="

    if [[ -z "$dir" ]]; then
      log "Skipping empty path in array"
      continue
    fi

    if [[ ! -d "$dir" ]]; then
      err "Directory not found: $dir -- skipping"
      ((failures++))
      continue
    fi

    # Change into the directory
    pushd "$dir" >/dev/null || { err "Failed to enter $dir"; ((failures++)); continue; }

    # Determine compose file presence
    if compfile=""; then :; fi
    if [[ -f "docker-compose.yml" ]]; then
      compfile="docker-compose.yml"
    elif [[ -f "docker-compose.yaml" ]]; then
      compfile="docker-compose.yaml"
    elif [[ -f "compose.yaml" ]]; then
      compfile="compose.yaml"
    elif [[ -f "docker-compose.override.yml" ]]; then
      compfile="docker-compose.override.yml"
    fi

    if [[ -z "${compfile}" ]]; then
      err "No docker-compose/compose file found in $dir -- skipping"
      popd >/dev/null
      ((failures++))
      continue
    fi

    log "Found compose file: $compfile"

    # Run the compose up command
    if $dc_cmd up -d --quiet-pull; then
      log "Started containers in $dir"
    else
      err "Failed to start containers in $dir"
      ((failures++))
    fi

    popd >/dev/null
  done

  if (( failures > 0 )); then
    err "Completed with $failures failure(s)."
    exit 4
  fi

  log "All compose projects processed successfully."
}

main "$@"
