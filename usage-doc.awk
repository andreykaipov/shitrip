function capitalize(s) {
     return toupper(substr(s, 1, 1)) substr(s, 2)
}

BEGIN {}

# get the cli description from the second line, after shebang line
NR==2 {
	desc=FILENAME
	if (match($0, /^# .+$/)) {
		k=length("# ")
		desc=substr($0, RSTART+k, RLENGTH-k)
	}
	print desc
}

/^[.] / {atsrc=1}
atsrc && $0=="" {afterheader=1}
# presumably comments with no indent after the header are fn comments.
# this treats the last comment before a fn as the command's short help text
afterheader && /^# (.+)/ {
	gsub(/^# /, "", $0)
	fncomment=$0
}

# either the beginning of multi-line, or one-line fns
# skip fns that begin with _
# skip fns that are only one letter
/^([^_][a-z0-9_]+)[(][)][ ][{]($|[ ].+;[ ][}]$)/ {
	fnname=$1
	gsub(/_/, " ", fnname)
	infn=1
	vari=1
}

# the end of a multiline fn or the end of a one-line one
# is when we print out the usage of the command
infn && (/^}$/ || /;[ ][}]$/) {
	infn=0
	split(fnname, words, " ")
	group=words[1]
	if (group != prevgroup) {
		print "###" # for column to produce empty lines
		printf "%s commands\n", capitalize(group)
	}
	printf "  %s", fnname

	for (i=1; i<vari; i++) {
		fn_var=fn_vars[fnname,i]
		printf " %s", fn_var
	}
	print "###" fncomment
	delete fn_vars
	vari=0
	fncomment=""
	prevgroup=group
}

# require-style args, e.g.
# : "${abc=$1}"
# : "${abc=${1?}}"
# : "${abc=${1?blah blah blah}}"
# infn && /^\s+:\s+"\$[{][a-z0-9_]+=\$([0-9]+|[{][0-9]+[?][^}]*[}])[}]"/ {
# 	invar=1
# 	arg="<"$3">"
# }
# different require-style args, e.g.
# abc=$1
# abc=${1?}
# abc=${1?blah blah blah}
# abc="$1"
# etc.
     # infn && /^\s+[a-z0-9_]+="?\$[{][0-9]+[?][^}]*[}]"?/ {
     # 	invar=1
     # 	gsub(/\s/, "", $1)
     # 	arg="<"$1">"
     # }
     # # optional positional args, e.g.
     # # : "${abc=${1-blah blah}}"
     # # and similar variations from above
     # infn && /^\s+:\s+"\$[{][a-z0-9_]+=\$([0-9]+|[{][0-9]+[-][^}]*[}])[}]"/ {
     # 	invar=1
     # 	arg="["$3"]"
     # }
     # # optional positional args, e.g.
     # # abc=${1-blah blah}
     # # and similar variations from above
     # infn && /^\s+[a-z0-9_]+="?\$([{]([0-9]+|[0-9]+[-][^}]*)[}])"?/ {
     # 	invar=1
     # 	gsub(/\s/, "", $1)
     # 	arg="["$1"]"
     # }
     # # required-style flags, e.g.
     # # : "${abc?some error message}"
     # infn && /^\s+:\s+"\$\{([a-z0-9_]+)[?][^}]*\}"/ {
     # 	invar=1
     # 	arg="--"$3"=<"$4">"
     # }
     # # optional-style flags, e.g.
     # # : "${abc=this is some default value}"
     # infn && /^\s+:\s+"\$\{([a-z0-9_]+)=[^}]*\}"/ {
     # 	invar=1
     # 	if (match($4, /[$]/)) $4="..." # if the default value has a $(...)
     # 	if ($4 != "") $4="="$4 # only include an = if there's a default value
     # 	arg="[--"$3$4"]"
     # }
# : "${abc-blah blah}" # this kind of variable expansion is a noop, so not handled
# the following are invalid assignments
# : "${1=blah}"
# : "${*=blah}"

# : "${@=blah}" # this is an invalid assignment normally, but takes a special meaning for us
infn {
#	if (match($0, /"[$][{]@=[^}]+/)) {
#		k=length("\"${@=")
#		arg=substr($0, RSTART+k, RLENGTH-k)
#		invar=1
#		arg="["arg"...]"
#	}

	arg=""

	# required_positional_a
	if (match($0, /^\s+[a-z0-9_]+="?[$][{]?[0-9]+[?][^}]*[}"]?[}"]?$/)) {
		gsub(/^\s*/, "", $1)
		arg="<"$1">"
	}
	# required_positional_b, colon variant of a
	if (match($0, /^\s+: "[$][{][a-z0-9_]+="?[$][{]?[0-9]+[?][^}]*[}"]?[}"]?[}]"$/)) {
		arg="<"$5">"
	}
	## optional_positional_a, e.g. abc=$1, abc="$2", abc=${3}, abc="${4}"
	if (match($0, /^\s+[a-z0-9_]+="?[$][{]?[0-9]+[}"]?[}"]?$/)) {
		gsub(/^\s*/, "", $1)
		arg="["$1"]"
	}
	# optional_positional_b, e.g. abc=${1-xyz}, abc="${1-xyz}", abc=${1:-xyz}, abc="${1:-xyz}"
	if (match($0, /^\s+[a-z0-9_]+="?[$][{]?[0-9]+:?-[^}]*[}"][}"]?$/)) {
		gsub(/^\s*/, "", $1)
		arg=$1
		gsub(/^\s*[a-z0-9_]+\s+[0-9]+\s*/, "", $0)
		gsub(/\s*$/, "", $0)
		arg="["arg"="$0"]"
	}
	# optional_positional_c, i.e. colon variant of a
	if (match($0, /^\s+: "[$][{][a-z0-9_]+="?[$][{]?[0-9]+[}"]?[}"]?[}]"$/)) {
		arg="["$5"]"
	}
	## optional_positional_d, i.e. colon variant of b
	if (match($0, /^\s+: "[$][{][a-z0-9_]+="?[$][{]?[0-9]+:?-[^}]*[}"][}"]?[}]"$/)) {
		gsub(/^\s*/, "", $1)
		arg=$5
		gsub(/^\s*[a-z0-9_]+\s+[0-9]+\s*/, "", $0)
		gsub(/\s*$/, "", $0)
		arg="["arg"="$0"]"
	}
	#
	# e.g. : ${abc=$1}
	#infn && /^\s+:\s+"\$[{][a-z0-9_]+=\$([0-9]+|[{][0-9]+[-][^}]*[}])[}]"/ {
}

# aggregates our vars per fn
infn && arg {
	gsub(/_/, "-", arg)
	fn_vars[fnname,vari] = arg
	vari++
	invar=0
}
