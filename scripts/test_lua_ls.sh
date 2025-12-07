#!/usr/bin/env bash

lua_ls=""
version=""
if [[ $# -eq 2 ]]; then
  lua_ls="$(realpath $1)"
  version="$2"
else
  echo "Usage: $0 /path/to/lua-language-server.appimage version"
  exit 1
fi

if ! $($lua_ls --appimage-help >/dev/null 2>&1); then
  echo "$lua_ls is not an AppImage"
  exit 2
fi

appimage_version=$($lua_ls --version)
fail=$?

if [ $fail -ne 0 ]; then
  cd $(dirname "$lua_ls")
  ./$(basename $lua_ls) --appimage-extract
  appimage_version=$(./squashfs-root/AppRun --version)
fi

if [[ "$appimage_version" != "$version" ]]; then
  echo "$lua_ls has version info: $appimage_version, expected: $version"
  exit 3
fi
