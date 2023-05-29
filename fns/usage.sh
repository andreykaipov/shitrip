#!/bin/sh

: "${usageawk=$(cat usage.awk)}"
input=${1-$0}
clishf=
if [ -n "$CLISH_EXTRAS" ]; then
        clishf=bin/bundle
fi

rawusage="$(awk -F '[()${}:=?]' "$usageawk" "$input" "$clishf")"
groups="$(printf "%s" "$rawusage" | awk '/^.+ commands$/ {print $1}')"

printf "%s" "$rawusage" | head -n1
printf '\n'

# pipe each section into column instead of the whole thing at once
for group in $groups; do
        printf "%s" "$rawusage" |
                awk -vg="$group" '$1==g,$0=="###"{print $0}' |
                column -t -s '#'
done
