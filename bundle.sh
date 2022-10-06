#!/bin/sh

: "${minify=}"

minifyawk() {
        if [ -z "$minify" ]; then cat && return; fi
        cat |
                sed -E 's/^\s*//g' |              # deindent
                sed -E 's/(^# .+$)|( # .+$)//g' | # remove single- and trailing-line comments
                sed -E '/^\s*$/d' |               # remove empty lines
                sed -z 's/{\n/{/g' |              # condense beginning of {} blocks
                sed -z 's/}\n/}/g' |              # condense end of {} blocks
                sed 's/if (/if(/g' |              # condense beginning of if
                sed 's/for (/for(/g' |            # condense beginning of for
                sed 's/ && /\&\&/g' |             # no spaces between &&
                sed 's/ || /||/g' |               # no spaces between ||
                # the following are kinda dangerous for general use
                # why have reliability when you can save like 2 bytes?
                sed 's/ {/{/g' | # no spaces before {
                sed 's/) /)/g' | # no spaces after )
                sed 's/, /,/g' | # no spaces between function args
                cat
}

main() {
        mkdir -p bin
        rm -rf bin/bundle

        cat >bin/bundle <<BUNDLE
# bundle
BUNDLE

        for f in usage help; do
                cat >>bin/bundle <<BUNDLE
$f() {
${f}awk=\$(
        cat <<'EOF'
$(minifyawk <$f.awk)
EOF
:
)
$(cat $f.sh)
}
BUNDLE
        done

        cat cli.sh >>bin/bundle

        if [ -n "$minify" ]; then
                shfmt --write --minify --posix bin/bundle
        fi
}

main
