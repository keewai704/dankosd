#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
destdir="${DESTDIR:-}"
prefix="${PREFIX:-/usr}"
dms_path="${DANKOSD_DMS_PATH:-/usr/share/quickshell/dms}"

[ -n "$destdir" ] || {
    echo "DESTDIR must be set for staging installs" >&2
    exit 2
}

bindir="$destdir$prefix/bin"
sharedir="$destdir$prefix/share/dankosd"
qmldir="$sharedir/qml"
examplesdir="$sharedir/examples"
systemd_user_dir="$destdir$prefix/lib/systemd/user"

install -d "$bindir" "$qmldir" "$examplesdir" "$systemd_user_dir"

install -Dm755 "$repo_root/bin/dankosd" "$bindir/dankosd"
ln -sfn dankosd "$bindir/dms-ddc-osd"

install -Dm644 "$repo_root/qml/shell.qml" "$qmldir/shell.qml"
install -Dm644 "$repo_root/qml/LevelOSD.qml" "$qmldir/LevelOSD.qml"
install -Dm644 "$repo_root/qml/DdcOsdState.qml" "$qmldir/DdcOsdState.qml"

for name in Common Widgets Services Modules Modals assets; do
    ln -sfn "$dms_path/$name" "$qmldir/$name"
done

install -Dm755 "$repo_root/integrations/ddcfast_osd.sh" "$examplesdir/ddcfast_osd.sh"
install -Dm644 "$repo_root/examples/hyprland/binds.conf" "$examplesdir/hyprland-binds.conf"

install -Dm644 "$repo_root/systemd/dankosd.service" "$systemd_user_dir/dankosd.service"
ln -sfn dankosd.service "$systemd_user_dir/dms-ddc-osd.service"
