#!/bin/sh

: "${help_awk_src=$(cat help.awk)}"
input=${1-$0}
awk -F '[()${}:=?]' -v fn="${fn?}" "$help_awk_src" "$input"
