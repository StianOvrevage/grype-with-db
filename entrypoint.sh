#!/bin/sh

tar --use-compress-program "zstd -T0" -xf grype-db.tar.zst
rm grype-db.tar.zst

exec "/usr/local/bin/grype" "$@"