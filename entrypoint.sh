#!/bin/sh

echo "Decompressing grype database..."

tar --use-compress-program "zstd -T0" -xvf grype-db.tar.zst
rm grype-db.tar.zst

exec "/usr/local/bin/grype" "$@"