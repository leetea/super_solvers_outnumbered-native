#!/bin/zsh
set -euo pipefail
repo_dir="${0:A:h}"
ditto -x -k "$repo_dir/source/runtime-data.zip" "$repo_dir/source"
staging_dir="$(mktemp -d /private/tmp/outnumbered-repository.XXXXXX)"
trap 'rm -rf "$staging_dir"' EXIT
app_name="Outnumbered Native Development.app"
zsh "$repo_dir/source/build.sh" "$staging_dir/$app_name"
mkdir -p "$repo_dir/build"
# Package the verified app without filesystem metadata. A ZIP remains portable
# when the checkout is inside a synced Documents folder.
archive="$repo_dir/build/Outnumbered-Native-Development.zip"
ditto -c -k --norsrc --noextattr --keepParent "$staging_dir/$app_name" "$archive"
echo "$archive"
