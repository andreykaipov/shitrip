BEGIN {
}

{
	if (match($0, /^([a-z_]+)[(][)][ ]\{$/)) {
		fnname=substr($0, RSTART, RLENGTH-1)
		infn=1
		vari=0
		delete fn_vars
		next
	}
}

/^}$/ {
	infn=0
	printf "%s", fnname
	for (x in fn_vars) {
		split(x, sep, SUBSEP)
		fn_var=fn_vars[sep[1],sep[2]]
		printf " %s", fn_var
	}
	print ""
}

infn {
	# match var assingments with or without comments
	#if (match($0, /^\s+([a-z0-9_]+)=\$([0-9]+)(\s+#\s+(.+)\s+?$|$)/, vars)) {
	if (match($0, /^\s+:\s+"\$\{([a-z0-9_]+)=\$([0-9]+)\}"(.+)/, vars)) {
		print substr($0, RSTART+1, RLENGTH-1)
		if (match(vars[3], /name: ([^,]+)/, tmp)) {
			vars[1]=tmp[1]
		}
		fn_vars[fnname,vari] = "<" vars[1] ">"
		vari++
	} else if (match($0, /^\s+:\s+"\$\{([a-z0-9_]+)=[^}]+\}"(\s+#\s+(.+)\s+?$|$)/, vars)) {
		if (match(vars[3], /name: ([^,]+)/, tmp)) {
			vars[1]=tmp[1]
		}
		fn_vars[fnname,vari] = "[" vars[1] "]"
		vari++
	}

}

END {
	position="position"
	comment="comment"
#	for (combo in fns) {
#		split(combo, sep, SUBSEP)
#		fnname=sep[1]
#		varname=sep[2]
#		print fnname, varname, fns[fnname,varname,position], fns[fnname,varname,comment]
#	}
}
