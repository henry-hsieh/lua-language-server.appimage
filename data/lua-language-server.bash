#!/usr/bin/env bash

APPIMAGE_DIR=$(dirname $(realpath $0))
LD_LIBRARY_PATH=${APPIMAGE_DIR}/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH} \
LLS_LOG_PATH=${LLS_LOG_PATH:-${XDG_STATE_HOME:-${HOME}/.local/state}/lua-language-server/log} \
LLS_META_PATH=${LLS_META_PATH:-${XDG_STATE_HOME:-${HOME}/.local/state}/lua-language-server/meta} \
${APPIMAGE_DIR}/usr/bin/lua-language-server "$@"