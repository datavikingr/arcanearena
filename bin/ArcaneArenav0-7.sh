#!/bin/sh
printf '\033c\033]0;%s\a' Arcane Arena
base_path="$(dirname "$(realpath "$0")")"
"$base_path/ArcaneArenav0-7.x86_64" "$@"
