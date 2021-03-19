# shitrip

It's a shitty shell script to make writing shell more fun, at least for me. :)

## usage

To use this shit, add the following to the top of your shell script, below your
shebang line:

```sh
command . shit.rip || eval "$(wget -qO- shit.rip)"
```

Or, the `curl` equivalent:

```sh
command . shit.rip || eval "$(curl -sLo- shit.rip)"
```

## example

Here's the contents of [examples/hellobud.sh](./examples/hellobud.sh):

```sh
#/bin/sh
# shellcheck disable=SC2154
command . shit.rip || eval "$(wget -qO- shit.rip)"

argr name

main() {
        echo "Hello bud, I am $name"
}
```

And here's our output when we run it:

```console
❯ ./examples/hellobud.sh
Usage: hellobud.sh <name>

Missing required positional argument: name

❯ ./examples/hellobud.sh Andrey
Hello bud, I am Andrey
```
