#!/usr/bin/env bash

set -eux -o pipefail
tempdir="$(mktemp -d)"
echo "temp dir created: $tempdir" >&2

function remove_tempdir {
  status="$?"
  set +x
  echo "removing tempdir: $tempdir" >&2
  rm -rf "$tempdir"
  return "$status"
}

trap "remove_tempdir" EXIT

base="$(cd "$(dirname "$0")" && pwd)"
cd "$tempdir"

if cat "$base/../bootstrap/init.sh" | bash; then
  set +x
  find .
  echo "OK"
else
  set +x
  echo "ERROR"
  echo "CURRENT files.dhall:"
  cat ./dhall/files.dhall || true
  exit 1
fi
