#!/bin/sh

mkdir -p bin
rm -rf bin/bundle

cat >bin/bundle <<BUNDLE
# bundle
BUNDLE

for f in usage help; do
        cat >>bin/bundle <<BUNDLE
$f() {
${f}_awk_src=\$(
        cat <<'EOF'
$(cat $f.awk)
EOF
:
)
$(cat $f.sh)
}
BUNDLE
done

cat cli.sh >>bin/bundle
