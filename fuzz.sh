#!/usr/bin/env bash

# usage: 
# source ~/dotfiles/fuzz.sh
# fuzz_fn n ...

_fuzz_impl() {
    local DURATION="$1"
    shift

    local end=$((SECONDS + DURATION))
    local iter=0

    echo "Running for $DURATION seconds..."
    echo "Command: $*"
    echo

    while [ $SECONDS -lt $end ]; do
        iter=$((iter + 1))

        echo "=== Iteration $iter @ $(date) ==="

        if ! "$@"; then
            echo "❌ FAILURE on iteration $iter @ $(date)"
            return 1
        fi

        echo "✅ Passed iteration $iter"
    done

    echo
    echo "✅ Finished $DURATION seconds with no failures (iterations: $iter)"
    return 0
}

fuzz_fn() {
    _fuzz_impl "$@"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    _fuzz_impl "$@" || exit 1
fi
