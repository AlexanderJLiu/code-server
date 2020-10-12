#!/usr/bin/env bash
set -euo pipefail

main() {
  cd "$(dirname "${0}")/../.."
  source ./ci/lib.sh

  rsync "$RELEASE_PATH/" "$RELEASE_PATH-standalone"
  RELEASE_PATH+=-standalone

  # We cannot find the path to node from $PATH because yarn shims a script to ensure
  # we use the same version it's using so we instead run a script with yarn that
  # will print the path to node.
  local node_path
  node_path="$(yarn -s node <<< 'console.info(process.execPath)')"

  mkdir -p "$RELEASE_PATH/bin"
  rsync ./ci/build/code-server.sh "$RELEASE_PATH/bin/code-server"
  rsync "$node_path" "$RELEASE_PATH/lib/node"

  ln -s "./bin/code-server" "$RELEASE_PATH/code-server"
  ln -s "./lib/node" "$RELEASE_PATH/node"

  # Have to make sure we have correct agent binary.
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  curl -fsSL "https://storage.googleapis.com/coder-cloud-releases/agent/latest/$OS/cloud-agent" -o "$RELEASE_PATH/lib/coder-cloud-agent"
  chmod +x "$RELEASE_PATH/lib/coder-cloud-agent"

  cd "$RELEASE_PATH"
  yarn --production --frozen-lockfile
}

main "$@"
