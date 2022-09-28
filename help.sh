#!/bin/sh

: "${help_awk_src=$(cat help.awk)}"

help() {
        input=${1-$0}
        awk -F '[()${}:=?]' -v fn="${fn?}" "$help_awk_src" "$input"
}

help "$@"
