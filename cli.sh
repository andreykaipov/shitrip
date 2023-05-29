#!/bin/sh

debug() {
        if [ -z "$DEBUG" ]; then return; fi
        if [ -n "$clishval" ]; then name="$f (clish)"; fi
        # current pid, parent pid
        printf "%b\n" "| ${name-$f} [$$,$PPID] | $*" >&2
}

fullpath() { echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"; }

# 1. read source to find all relevant functions that are commands
# 2. append _ to each of them to prevent something like `run asd` from matching `run a` when both `run()` and `run_a()` exist.
# 3. match user input $* against the relevant fns to find the one we want to call
# 4. based on how long the cmd is, shift the user input by that amount so we can pass the right args to the cmd
# 5. parse flags and positional args
# 6. execute the cmd
wrapper() {
        fns="$(awk -F'[()]' '/^([^_][a-z0-9_]+)[(][)][ ][{]($|[ ].+;[ ][}]$)/ {print $1"_"}' "$f")"
        cmd="$(echo "$* " | tr ' ' _ | grep -o "$fns" | sed 's/.$//' || :)"
        debug "user cmd: <$*>"
        debug "fns* to match user cmd cmd against: \n$fns"
        debug "matched cmd: $cmd"
        if [ -z "$cmd" ]; then usage && exit 1; fi
        notargs="$(echo "$cmd" | awk -F_ '{print NF}')"
        shift "$notargs"

        # iterate over $@, distinguishing between flags and positional args,
        # exposing any flags as vars in the called fn.
        #
        # note: this should NOT be its own function. since args might have
        # spaces, we have to edit $@ to stay posix to fight against word
        # splitting. the alternative is editing the IFS after calling the
        # proposed fn, but that assumes user input. it ain't worth the trouble.
        i=0
        numargs="$#"
        while [ $i -lt "$numargs" ]; do
                case "$1" in
                        --)
                                # end of flags, treat anything after as positional, so
                                # it's possible to pass $@ to other commands unmodified
                                shift
                                x=$((numargs - 1 - i))
                                while [ $x -gt 0 ]; do
                                        set -- "$@" "$1"
                                        shift
                                        x=$((x - 1))
                                done
                                break
                                ;;
                        --*)
                                # consider using ## and %% param substitution
                                optval="$(echo "$1" | cut -c3-)"       # remove --
                                opt="$(echo "$optval" | cut -d= -f1)"  # get flag
                                val="$(echo "$optval" | cut -d= -f2-)" # get after first =
                                if [ -z "$val" ]; then val=''; fi      # --opt=, empty is intentional
                                if [ "$opt" = "$val" ]; then val=1; fi # --opt, quirk of cut when no delimiter
                                opt="$(echo "$opt" | tr - _)"          # underscore any dashes
                                eval "$opt='$val'"
                                debug "Flag $opt=$val"
                                ;;
                        *)
                                set -- "$@" "$1" # anything else is positional
                                ;;
                esac
                shift
                i=$((i + 1))
        done

        debug "New \$*: $*"
        usagedef="$(help | grep '^args:' | cut -d' ' -f2-)"

        if [ -n "$help" ]; then
                fn="$cmd" help
                return
        fi

        $cmd "$@"
}

f=$0
fname=$(basename "$f")
fslug=$(printf "%s" "$fname" | tr -c -- 'a-zA-Z0-9_' _)
clishvar=__clish_$fslug
clishval=$(eval "echo \"\$$clishvar\"")
debug "sourced this lib"
if [ -n "$clishval" ]; then
        debug "but clish is already available"
        return
fi

exec env "$clishvar=1" sh -s -c "$(
        cat <<'EOF'
        . "$0"
        debug "running modified script inside execed shell"
        wrapper "$@"
EOF
        :
)" "$0" "$@"
