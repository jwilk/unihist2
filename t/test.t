#!/usr/bin/env bash

# Copyright © 2021 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u

here="${0%/*}"
base="$here/.."
prog="${UNIHIST2_TEST_TARGET:-"$base/unihist2"}"
declare -i n
n=$(ls -q "$here"/*.exp | wc -l)
echo "1..$n"
n=0
for file in "$here"/*.exp
do
    n+=1
    check=${file##*/}
    case $file in
        *.g.exp)
            txt=${file%.g.exp}.txt
            options=(-G)
            ;;
        *)
            txt=${file%.exp}.txt
            options=()
            ;;
    esac
    out=$("$prog" "${options[@]}" < "$txt")
    diff=$(diff -u "$file" <(cat <<< "$out")) || [ $? -eq 1 ]
    if [ -z "$diff" ]
    then
        echo "ok $n $check"
    else
        sed -e 's/^/# /' <<< "$diff"
        echo "not ok $n $check"
    fi
done

# vim:ts=4 sts=4 sw=4 et ft=sh
