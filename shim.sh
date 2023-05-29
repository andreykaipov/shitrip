#!/bin/sh

debug() {
        if [ -z "$DEBUG" ]; then return; fi
        echo >&2 "| shitrip.shim | $* "
}

# if you've got a : in one of your PATH directories, shit won't work.
# but... why would you do such a thing, you evil evil person?

IFS=:
for d in $PATH; do
        if [ -w "$d" ]; then
                debug "Found writeable directory '$d' on your PATH"
                found=1
                break
        fi
done

if [ -z "$found" ]; then
        "Couldn't find a writeable directory on your PATH" >&2
        "Bye" >&2
        exit 1
fi

get() {
        if command -v wget >/dev/null; then
                wget -qO "$@"
        elif command -v curl >/dev/null; then
                curl -sLo "$@"
        else
                echo >&2 "Sorry - can't shit without wget or curl"
                echo >&2 "How did you even run this without wget or curl?"
                exit 1
        fi
}

debug "Vendoring shit into '$d'"

# get "$d/shit.rip" shit.rip/shit

#. shit.rip
