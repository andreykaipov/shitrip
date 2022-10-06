# Grabs the comments block before a given function `fn`
/^#$/ || /^# .+$/ { comments[i++]=substr($0, 3) }
$1 == fn { exit }
/^[^#]/ { delete comments; i=1 }
END { for (i in comments) print comments[i] }
