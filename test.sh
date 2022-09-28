#!/bin/sh

set -eu

main() {
        ./bundle.sh

        for t in variations_usage help_text; do
                if $t; then
                        echo "\e[32m$t: success\e[0m"
                        continue
                fi

                echo "\e[31m$t: error\e[0m"
                cd /tmp
                echo "$expected" >expected
                echo "$actual" >actual
                diff --unified expected actual
        done
}

variations_usage() {
        expected=$(
                cat <<'EOF'
Example CLI showcasing different variations, doubles as test cases too

Optional commands
  optional positional a [arg1] [arg2] [arg3] [arg4]                                    shows off the a style of optional positionals
  optional positional b [arg1] [arg2] [arg3] [arg4]                                    shows off the b style (i.e. colon variant of a)
  optional positional c [arg1=...] [arg2=def val 2] [arg3=def val 3] [arg4=def val 4]  shows off the c style of optional positionals
  optional positional d [arg1=...] [arg2=def val y] [arg3=def val z] [arg4=def val q]  shows off the d style (i.e. colon variant of c)
  optional flag [--arg1=...] [--arg2=def val 1] [--arg3= ] [--arg4]                    shows off optional flags

Required commands
  required positional a <arg1> <arg2> <arg3> <arg4>  shows off the a style of required positionals
  required positional b <arg1> <arg2> <arg3> <arg4>  shows off the b style (i.e. colon variant of a)
  required flag --arg1 --arg2=... --arg3 --arg4=...  shows off required flags

Misc commands
  misc [pizza...]  shows off multiple args
EOF
        )
        actual="$(./variations.sh)"
        test "$expected" = "$actual"
}

help_text() {
        expected=$(
                cat <<'EOF'

shows off multiple args

switch case is important here

multi line comment to show off help and first fn line comment usage

EOF
        )
        actual="$(help=1 ./variations.sh misc)"
        test "$expected" = "$actual"
}

main "$@"
