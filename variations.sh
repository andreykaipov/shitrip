#!/bin/sh
# Example CLI showcasing different variations, doubles as test cases too

. ./bin/bundle

####
#### optional positionals
####

# shows off the a style of optional positionals
optional_positional_a() {
        arg1=$1
        arg2="$2"
        arg3=${3}
        arg4="${4}"
        echo "1=$arg1; 2=$arg2; 3=$arg3; 4=$arg4"
}

# shows off the b style (i.e. colon variant of a)
optional_positional_b() {
        : "${arg1=$1}"
        : "${arg2="$2"}"
        : "${arg3=${3}}"
        : "${arg4="${4}"}"
        echo "1=$arg1; 2=$arg2; 3=$arg3; 4=$arg4"
}

# shows off the c style of optional positionals
optional_positional_c() {
        arg1=${1-$(ls def val 1)} && ls -al
        arg2="${2-def val 2}"
        arg3=${3:-def val 3}
        arg4="${4:-def val 4}"
        echo "1=$arg1; 2=$arg2; 3=$arg3; 4=$arg4"
}

# shows off the d style (i.e. colon variant of c)
optional_positional_d() {
        : "${arg1=${1-$(ls def val x)}}" && ls -al
        : "${arg2="${2-def val y}"}"
        : "${arg3=${3:-def val z}}"
        : "${arg4="${4:-def val q}"}"
        echo "1=$arg1; 2=$arg2; 3=$arg3; 4=$arg4"
}

####
#### optional flags
####

# shows off optional flags
optional_flag() {
        : "${arg1="$other"}"
        : "${arg2=def val 1}"
        : "${arg3= }"
        : "${arg4=}"
        echo "1=$arg1; 2=$arg2; 3=$arg3; 4=$arg4"
}

####
#### required positionals
####

# shows off the a style of required positionals
required_positional_a() {
        arg1=${1?}
        arg2=${2?req msg 1}
        arg3="${1:?}"
        arg4="${2:?req msg 2}"
        echo "1=$arg1; 2=$arg2; 3=$arg3; 4=$arg4"
}

# shows off the b style (i.e. colon variant of a)
required_positional_b() {
        : "${arg1=${1?}}"
        : "${arg2=${2?req msg 1}}"
        : "${arg3="${1:?}"}"
        : "${arg4="${2:?req msg 2}"}"
        echo "1=$arg1; 2=$arg2; 3=$arg3; 4=$arg4"
}

####
#### required flags
####

# shows off required flags
# blah
required_flag() {
        : "${arg1?}" && ls -al
        : "${arg2?req msg 1}" && ls -al
        : "${arg3:?}"
        : "${arg4:?req msg 2}"
        echo "1=$arg1; 2=$arg2; 3=$arg3; 4=$arg4"
}

####
#### misc
####

#
# shows off multiple args
#
# switch case is important here
#
# multi line comment to show off help and first fn line comment usage
#
misc() {
        case $# in
                0) echo nothing ;;
                *) echo "${@=pizza}" ;;
        esac
}

####
