#!/bin/sh

mkdir -p bin
rm -rf bin/bundle

cat >bin/bundle <<BUNDLE
#!/bin/sh
# bundle
BUNDLE

for f in usage help; do
        cat >>bin/bundle <<BUNDLE
${f}_awk_src=\$(
        cat <<'EOF'
$(cat $f.awk)
EOF
)
$(grep -v "$f"' "$@"' $f.sh)
BUNDLE
done

chmod +x bin/bundle
