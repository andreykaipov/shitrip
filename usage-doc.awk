BEGIN {
}

/^# usage: (.+)/ {
	gsub(/^ /, "", $3)
	usage=$3
}

/^([a-z_]+)[(][)][ ]\{$/ {
	fnname=$1
	infn=1
}

/^}$/ {
	if (fnname == "main") next

	infn=0
	gsub(/_/, " ", fnname)
	printf "%s", fnname
	for (x in fn_vars) {
		split(x, sep, SUBSEP)
		fn_var=fn_vars[sep[1],sep[2]]
		printf " %s", fn_var
	}
	print " ... " usage
	delete fn_vars
	vari=0
	usage=""
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
	arg="<"$1">"
}

# optional-style args, e.g.
# : "${abc=this is some default value}"
infn && /^\s+:\s+"\$\{([a-z0-9_]+)=[^}]*\}"/ {
	invar=1
	if (match($4, /[$]/)) $4="..."
	if ($4 != "") $4="="$4
	arg="["$3$4"]"
}

infn && invar {
	gsub(/\s/, "", arg)
	gsub(/_/, "-", arg)
	if (match($0, /name: [^, ]+/)) {
		k=length("name: ")
		argtmp=substr($0, RSTART+k, RLENGTH-k)
		arg=substr(arg, 0, 1) argtmp substr(arg, length(arg), 1) # adds brackets back in
	}
	fn_vars[fnname,vari] = arg
	vari++
	invar=0
}

	#print $1, $2, $3, $4, $5, $6, $7, $8
