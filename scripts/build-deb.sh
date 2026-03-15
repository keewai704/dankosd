#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
version="${VERSION:-$("$repo_root/scripts/version.sh")}"
arch="${DEB_ARCH:-$(dpkg --print-architecture)}"
output_dir="${OUTPUT_DIR:-$repo_root/dist}"
pkgroot="$(mktemp -d)"
trap 'rm -rf "$pkgroot"' EXIT

mkdir -p "$output_dir"

DESTDIR="$pkgroot" PREFIX=/usr "$repo_root/scripts/stage-system.sh"
mkdir -p "$pkgroot/DEBIAN"

cat >"$pkgroot/DEBIAN/control" <<EOF
Package: dankosd
Version: $version
Section: utils
Priority: optional
Architecture: $arch
Maintainer: KY <249657796+keewai704@users.noreply.github.com>
Description: Generic DMS-styled standalone OSD for Quickshell
 dankosd shows icon-and-level OSDs in a style that matches
 DankMaterialShell while staying as a separate Quickshell config.
EOF

dpkg-deb --build --root-owner-group "$pkgroot" "$output_dir/dankosd_${version}_${arch}.deb"
