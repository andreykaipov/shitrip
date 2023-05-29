#!/bin/sh
# Example CLI using shit.sh, imitating a small subset of Docker's CLI layout

# enjoy
. ./bin/bundle
. ./shit.sh

# connect a container to a network
network_connect() {
        network=$1
        container=$2
        : "${alias= }"
        : "${ip=127.0.0.1}"
        echo "Connected $container to $network"
}
# create a network
network_create() {
        network=$1
        : "${attachable=}"
        : "${ingress=}"
        echo "Created $network"
}
# disconnect a container from a network
network_disconnect() {
        network=$1
        container=$2
        : "${force=}"
        echo "Disconnected $container to $network"
}
# display detailed info on one or more networks
network_inspect() {
        network=${1?at least one network is required}
        case $# in
                0) ;;
                1) echo "Inspected $network with (format=$format; verbose=$verbose)" ;;
                *) for x in "${@=networks}"; do network_inspect "$x"; done ;;
        esac
        : "${format=$some_default_format}"
        : "${verbose=}"
}
# list networks
network_ls() {
        : "${filter=$some_default_filter}"
        : "${format=$some_default_format}"
        : "${no_trunc=}"
        : "${quiet=}"
}
# remove all unused networks
network_prune() {
        : "${filter=}"
        : "${force=}"
}
# remove one or more networks
network_remove() {
        network=${1?at least one network is required}
        case $# in
                0) ;;
                1) echo "Removed $network" ;;
                *) for x in "${@=networks}"; do network_remove "$x"; done ;;
        esac
}

# ls
context_ls() { :; }
context_list() { :; }
context_create() {
        : "${default_stack_orchestrator?}"
        : "${default_stack_orchestrator=}"
}
