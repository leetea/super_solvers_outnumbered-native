#!/bin/zsh
set -euo pipefail
repo_dir="${0:A:h}"
ditto -x -k "$repo_dir/source/runtime-data.zip" "$repo_dir/source"
staging_dir="$(mktemp -d /private/tmp/outnumbered-repository-final.XXXXXX)"
trap 'rm -rf "$staging_dir"' EXIT
zsh "$repo_dir/source/build.sh" "$staging_dir/Outnumbered.app" release
mkdir -p "$repo_dir/build"
archive="$repo_dir/build/Outnumbered-1.0.zip"
ditto -c -k --norsrc --noextattr --keepParent "$staging_dir/Outnumbered.app" "$archive"
echo "$archive"
