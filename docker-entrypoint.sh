#!/bin/sh
set -e

defaults="--http-addr=0.0.0.0:3000 --electrum-txs-limit=25000"

for def in $defaults; do
    flag=$(echo "$def" | cut -d= -f1)
    skip=0
    for arg in "$@"; do
        case "$arg" in
            "$flag"*) skip=1; break ;;
        esac
    done
    if [ $skip -eq 0 ]; then
        set -- "$def" "$@"
    fi
done

exec electrs "$@"
