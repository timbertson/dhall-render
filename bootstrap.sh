#!/usr/bin/env bash
function main {
	set -eu
	files_path="dhall/files.dhall"
	function download {
		echo >&2 "Downloading $* ..."
		curl -sSL -H 'Cache-Control: no-cache' "$@"
	}

	BASE="https://raw.githubusercontent.com/SebastianKG/dhall-render"

	if [ -e "$files_path" ]; then
		echo >&2 "Note: $files_path already exists, reusing it"
	else
		echo >&2 "Initializing $files_path ..."
		contents="$(download "$BASE/master/bootstrap/files.dhall")"
		if [ -z "$contents" ]; then
			echo >&2 "Error: couldn't fetch files.dhall template"
		fi
		mkdir -p "$(dirname "$files_path")"
		echo "$contents" > "$files_path"
	fi

	echo >&2 "Running initial render ..."
	ruby <(download "$BASE/master/lib/dhall_render.rb" && echo "main") "$files_path"

	echo >&2 "Pinning to current commit ..."
	set -x
	./dhall/bump --to timbertson/dhall-render:master "$files_path"
	./dhall/fix "$files_path"
	./dhall/render
}
main
