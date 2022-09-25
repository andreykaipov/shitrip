function capitalize(s) {
     return toupper(substr(s, 1, 1)) substr(s, 2)
}

BEGIN {
	description=ARGV[1]
	inheader=1
	print ARGV[1]
}

inheader && /^# description:/ {
	if (match($0, /# description: .+/)) {
		k=length("# description: ")
		description=substr($0, RSTART+k, RLENGTH-k)
	}
	print "\033[2A"
	print description
	inheader=""
}

!infn && /^# (.+)/ {
	gsub(/^ /, "", $0)
	comment=$0
}

# either the beginning of multi-line, or one-line fns
# skip fns that begin with _
# skip fns that are only one word
/^([^_][a-z_]+_[a-z_]+)[(][)][ ][{]($|[ ].+;[ ][}]$)/ {
	fnname=$1
	infn=1
}

# the end of a multiline fn or the end of a one-line one
infn && (/^}$/ || /;[ ][}]$/) {
	infn=0
	gsub(/_/, " ", fnname)
	split(fnname, words, " ")
	group=words[1]
	if (group != prevgroup) {
		print "###"
		printf "%s commands\n", capitalize(group)
	}
	printf "  %s", fnname

	for (x in fn_vars) {
		split(x, sep, SUBSEP)
		fn_var=fn_vars[sep[1],sep[2]]
		printf " %s", fn_var
	}
	print " ### " comment
	delete fn_vars
	vari=0
	comment=""
	prevgroup=group
}

# require-style args, e.g.
# : "${abc=$1}"
# : "${abc=${1?}}"
# : "${abc=${1?blah blah blah}}"
infn && /^\s+:\s+"\$[{][a-z0-9_]+=\$([0-9]+|[{][0-9]+[?][^}]*[}])[}]"/ {
	invar=1
	arg="<"$3">"
}
# different require-style args, e.g.
# abc=$1
# abc=${1?}
# abc=${1?blah blah blah}
# abc="$1"
# etc.
infn && /^\s+[a-z0-9_]+="?\$([0-9]+|[{][0-9]+[?][^}]*[}])"?/ {
	invar=1
	gsub(/\s/, "", $1)
	arg="<"$1">"
}
# optional positional args, e.g.
# : "${abc=${1-blah blah}}"
# and similar variations from above
infn && /^\s+:\s+"\$[{][a-z0-9_]+=\$([0-9]+|[{][0-9]+[-][^}]*[}])[}]"/ {
	invar=1
	arg="["$3"]"
}
# optional positional args, e.g.
# abc=${1-blah blah}
# and similar variations from above
infn && /^\s+[a-z0-9_]+="?\$([0-9]+|[{][0-9]+[-][^}]*[}])"?/ {
	invar=1
	gsub(/\s/, "", $1)
	arg="["$1"]"
}
# required-style flags, e.g.
# : "${abc?some error message}"
infn && /^\s+:\s+"\$\{([a-z0-9_]+)[?][^}]*\}"/ {
	invar=1
	arg="--"$3"=<"$4">"
}
# optional-style flags, e.g.
# : "${abc=this is some default value}"
infn && /^\s+:\s+"\$\{([a-z0-9_]+)=[^}]*\}"/ {
	invar=1
	if (match($4, /[$]/)) $4="..." # if the default value has a $(...)
	if ($4 != "") $4="="$4 # only include an = if there's a default value
	arg="[--"$3$4"]"
}

infn && invar {
	gsub(/_/, "-", arg)
	fn_vars[fnname,vari] = arg
	vari++
	invar=0
}
