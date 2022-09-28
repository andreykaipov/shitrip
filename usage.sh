#!/bin/sh

: "${usage_awk_src:=$(cat usage.awk)}"

usage() {
        input=${1-$0}

        rawusage="$(awk -F '[()${}:=?]' "$usage_awk_src" "$input")"
        groups="$(printf "%s" "$rawusage" | awk '/^.+ commands$/ {print $1}')"

        printf "%s" "$rawusage" | head -n1
        printf '\n'

        # pipe each section into column instead of the whole thing at once
        for group in $groups; do
                printf "%s" "$rawusage" |
                        awk -vg="$group" '$1==g,$0=="###"{print $0}' |
                        column -t -s '#'
        done
}

usage "$@"
