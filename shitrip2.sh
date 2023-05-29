#!/bin/sh
# vim: filetype=sh
#
# This script has two halves, and they're separated by a large turd.
#
# The first time this script is sourced, only the second half is relevant. It
# preprocesses the script that sourced this file, and then exec's it in a new
# shell, adding in the `__wrapper "$@"` invocation.
#
# The second time this script is sourced, the first half is relevant. It defines
# functions that could be used in our original script (e.g. argr and argo).
#
#     - Technically these functions are also available during the first source,
#       since well... it comes first, but they're not really relevant. Overhead
#       is minimal since it's mostly just function definitions, apart from the
#       conditional logic to stop the second source from bleeding into the
#       second half.

debug() {
        if [ -z "$DEBUG" ]; then return; fi
        if [ -n "$shitval" ]; then name="*$f*"; fi
        # current pid, parent pid
        printf '%s\n' "| ${name-$f} [$$,$PPID] | $*" >&2
}

fullpath() {
        echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"
}

f="$0"
fname="$(basename "$f")"
fslug="$(printf "%s" "$fname" | tr -c -- 'a-zA-Z0-9_' _)"
shitvar="__shittified_$fslug"
shitval="$(eval "echo \"\$$shitvar\"")"
debug "$fname $fslug shitvar=$shitvar shitval=$shitval"
debug "sourced this lib"
if [ -n "$shitval" ]; then
        debug "but it was already shit"
        return
fi

awk -f shitrip.awk "$f"
#sourcemod="$(
#        debug 'modifying source'
#        awk 2>/dev/null '
#                /^argr/ { $3="\"\$@\"; shift"; print; next }
#                /^argo/ { $3="\"\$@\"; shift 2>/dev/null"; print; next }
#                1
#        ' "$f"
#)"
#
#debug "source contents:"
#debug "$sourcemod"
#debug "source end"
