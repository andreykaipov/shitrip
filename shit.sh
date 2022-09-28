#!/bin/sh

debug() {
        if [ -z "$DEBUG" ]; then return; fi
        if [ -n "$shitval" ]; then name="$f (shit)"; fi
        # current pid, parent pid
        printf "%b\n" "| ${name-$f} [$$,$PPID] | $*" >&2
}

fullpath() { echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"; }

# 1. read source to find all relevant functions that are commands
# 2. append _ to each of them to prevent something like `run asd` from matching `run a` when both `run()` and `run_a()` exist.
# 3. match user input $* against the relevant fns to find the one we want to call
# 4. based on how long the cmd is, shift the user input so we can pass the right args to the cmd
# 5. execute the cmd
wrapper() {
        fns="$(awk -F'[()]' '/^([^_][a-z0-9_]+)[(][)][ ][{]($|[ ].+;[ ][}]$)/ {print $1"_"}' "$f")"
        cmd="$(echo "$* " | tr ' ' _ | grep -o "$fns" | sed 's/.$//' || :)"
        debug "user cmd: <$*>"
        debug "fns* to match user cmd cmd against: \n$fns"
        debug "matched cmd: $cmd"
        if [ -z "$cmd" ]; then usage && exit 1; fi
        notargs="$(echo "$cmd" | awk -F_ '{print NF}')"
        shift "$notargs"

        if [ -n "$help" ]; then
                fn="$cmd" help
                return
        fi

        $cmd "$@"
}

f=$0
fname=$(basename "$f")
fslug=$(printf "%s" "$fname" | tr -c -- 'a-zA-Z0-9_' _)
shitvar=__shit_$fslug
shitval=$(eval "echo \"\$$shitvar\"")
debug "sourced this lib"
if [ -n "$shitval" ]; then
        debug "but it was already shit"
        return
fi

exec env "$shitvar=1" sh -s -c "$(
        cat <<'EOF'
        . "$0"
        debug "running modified script inside execed shell"
        wrapper "$@"
EOF
)" "$0" "$@"
