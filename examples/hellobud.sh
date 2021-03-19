#!/bin/sh
# shellcheck disable=SC2154
command . shit.rip || eval "$(wget -qO- shit.rip)"

argr name

main() {
        echo "Hello bud, I am $name"
}
