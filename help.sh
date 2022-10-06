#!/bin/sh

: "${helpawk=$(cat help.awk)}"
input=${1-$0}
awk -F '[()${}:=?]' -v fn="${fn?}" "$helpawk" "$input"
