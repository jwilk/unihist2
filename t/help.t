#!/usr/bin/env bash

# Copyright © 2024 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u

here="${0%/*}"
base="$here/.."
prog="${UNIHIST2_TEST_TARGET:-"$base/unihist2"}"
echo 1..1
xout=$(
    < "$base/README" \
    grep '^   [$] unihist2 --help$' -A999 |
    tail -n +2 |
    grep -B999 '^   [$]' |
    head -n -1 |
    sed -e 's/^   //'
)
out=$("$prog" --help)
say() { printf "%s\n" "$@"; }
diff=$(diff -u <(say "$xout") <(say "$out")) || true
if [ -z "$diff" ]
then
    sed -e 's/^/# /' <<< "$out"
    echo 'ok 1'
else
    sed -e 's/^/# /' <<< "$diff"
    echo 'not ok 1'
fi

# vim:ts=4 sts=4 sw=4 et ft=sh
