#!/bin/sh
set -e

defaults="--http-addr=127.0.0.1:3001 --utxos-limit=25000 --electrum-txs-limit=25000"

http_override=0
for arg in "$@"; do
    case "$arg" in
        --http-addr=*) http_override=1; break ;;
    esac
done

if [ $http_override -eq 0 ]; then
    nginx -g 'daemon off;' &
fi

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
