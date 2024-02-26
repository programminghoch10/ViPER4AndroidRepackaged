#!/bin/bash
export IFS=$'\n'
[ -z "$(command -v shellcheck)" ] && echo "shellcheck not installed!" >&2 && exit 1
shellcheck --version

declare -a FILES
mapfile -t FILES < <(find . -type f -name '*.sh')

shellcheck \
    --wiki-link-count=256 \
    "$@" \
    "${FILES[@]}"
