#!/bin/sh
# shellcheck disable=SC1090,SC1091

log() { printf >&2 '\e[0;36m%s\e[0m' "$1"; }
logln() { printf >&2 '\e[0;36m%s\e[0m\n' "$1"; }
warningln() { printf >&2 '\e[1;33m%s\e[0m\n' "$1"; }
errorln() { printf >&2 '\e[1;31m%s\e[0m\n' "$1"; }

# We're safe splitting on : because the POSIX spec tells us we can.
#
# From: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
#
# > The prefixes shall be separated by a <colon> ( ':' ).
# > ...
# > Since <colon> is a separator in this context, directory names that might be
# > used in PATH should not include a <colon> character.
#
# Plus, why on earth would anybody try and do such an evil thing?

find_writeable_pathdirs() {
        set -f
        old_ifs="$IFS"

        IFS=:
        for d in $PATH; do
                if [ -w "$d" ]; then
                        printf '%s\n' "$d"
                fi
        done

        IFS="$old_ifs"
        set +f
}

main() {
        dirs="$(find_writeable_pathdirs)"

        if [ -z "$dirs" ]; then
                log "Couldn't find a writeable directory on your PATH"
                log "Bye"
                exit 1
        fi

        logln "Found the following writeable dirs on your PATH..."
        logln "Please select one where we can rip our fat shit:"
        logln

        i=1
        IFS='
'
        for d in $dirs; do
                printf "%2s %s\n" "$i" "$d"
                i=$((i + 1))
        done

        logln

        while :; do
                log "Choice: "
                read -r choice

                case "$choice" in
                        *[!0-9]*) ;;
                        '') ;;
                        *) break ;;
                esac
        done

        i=1
        for d in $dirs; do
                if [ "$choice" = "$i" ]; then
                        break
                fi
                i=$((i + 1))
        done

        logln
        log "Vendoring shit.rip into: "
        printf '%s\n' "$d"

        cp bin/bundle "$d/clish"
        #        f="$d/shit.rip"
        #        get "$f" shit.rip/shit
        #
        #        if command -v md5sum >/dev/null; then
        #                if ! echo "$md5  $f" | md5sum -c -; then
        #                        errorln "Aborting"
        #                        rm "$f"
        #                        exit 1
        #                fi
        #        else
        #                logln
        #                warningln "Cannot verify md5sum"
        #        fi
        #
        logln
        logln "Feel free to source it from any shell script now"
}

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

md5=4ba886dc363a3a60fa3b70ddbe35b5f0
main "$@"
