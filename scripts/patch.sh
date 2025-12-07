#!/usr/bin/env bash

if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 <package> <version> <build_dir>"
  exit 1
fi
# Patch packages for specific versions

scripts_dir="$(dirname $(realpath $0))"
package="$1"
version="$2"
build_dir="$(realpath $3)"

if [[ "$package" == "lua-language-server" ]]; then
  target="3.16.0"
  # patch version string if version >= 3.16.0 (target)
  if [ "$(printf '%s\n%s' "$target" "$version" | sort -V | head -n1)" = "$target" ]; then
    git -C 3rd/luamake reset HEAD --hard
    patch -d 3rd/luamake -p1 -i $scripts_dir/patch/lua-language-server-3.16.0.patch
  fi
fi
