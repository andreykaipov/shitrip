# Generates an unformatted usage function for a POSIX shell script

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
# this treats the first comment before a fn as the command's short help text
afterheader && !fncomment && /^# (.+)/ {
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
		printf "%s commands\n", toupper(substr(group, 1, 1)) substr(group, 2)
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

infn {
	arg=""

	gsub(/^\s*/, "", $0)         # trim leading whitespace from each line in a fn
	gsub(/"/, "", $0)            # trim quotes
	gsub(/[}]\s+&&.+$/, "}", $0) # trim ending in case its variable declaration ends with &&

	# normally something like "${@=blah}" is an invalid assignment, but it
	# takes a special meaning for us - to indicate variable usage
	if (match($0, /[$][{]@=[^}]+/)) {
		k=length("${@=")
		arg=substr($0, RSTART+k, RLENGTH-k)
		invar=1
		arg="["arg"...]"
	}
	# required_positional_a, e.g.
	# abc=${123?xyz}
	else if (match($0, /^[a-z0-9_]+=[$][{][0-9]+:?[?].*[}]$/)) {
		arg="<"$1">"
	}
	# required_positional_b, colon variant of a, e.g.
	# : ${abc=${123?xyz}}
	else if (match($0, /^: [$][{][a-z0-9_]+:?=[$][{][0-9]+:?[?].*[}][}]$/)) {
		arg="<"$4">"
	}
	# optional_positional_a, e.g.
	# abc=$1 or abc=${1}
	else if (match($0, /^[a-z0-9_]+=[$][{]?[0-9]+[}]?$/)) {
		arg="["$1"]"
	}
	# optional_positional_b, i.e. colon variant of a, e.g.
	# : ${abc=$1} or : ${abc=${1}}
	else if (match($0, /^: [$][{][a-z0-9_]+=[$][{]?[0-9]+[}]?[}]$/)) {
		arg="["$4"]"
	}
	# optional_positional_c, e.g.
	# abc=${1-xyz}
	else if (match($0, /^[a-z0-9_]+=[$][{][0-9]+:?[-].*[}]$/)) {
		arg=$1
		split($0, xxxval, /[-}]/)
		val=xxxval[2]
		if (substr(val, 0, 1)=="$") val="..."
		arg="["arg"="val"]"
	}
	# optional_positional_d, colon variant of optional_positional_c, e.g.
	# : ${abc=${1-xyz}}
	else if (match($0, /^: [$][{][a-z0-9_]+=[$][{][0-9]+:?[-].*[}][}]$/)) {
		arg=$4
		split($0, xxxval, /[-}]/)
		val=xxxval[2]
		if (substr(val, 0, 1)=="$") val="..."
		arg="["arg"="val"]"
	}
	# required_flag, e.g.
	# : ${abc?xyz}
	else if (match($0, /^: [$][{][a-z0-9_]+:?[?].*[}]$/)) {
		arg=$4
		split($0, xxxval, /[?}]/)
		val=xxxval[2]
		if (val!="") val="=..."
		arg="--" arg val
	}
	# optional_flag, e.g.
	# : ${abc=...}
	# note this will match any colon assignment style pattern, so must be last
	else if (match($0, /^: [$][{][a-z0-9_]+:?[=].*[}]$/)) {
		arg=$4
		split($0, xxxval, /[=}]/)
		val=xxxval[2]
		if (val!="" && substr(val, 0, 1)=="$") val="=..."
		arg="[--" arg val "]"
	}
}

# aggregates our vars per fn
infn && arg {
	gsub(/_/, "-", arg)
	fn_vars[fnname,vari] = arg
	vari++
	invar=0
}
