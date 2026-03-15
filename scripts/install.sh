#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
quickshell_dir="$config_home/quickshell/ddc-osd"
bin_dir="$HOME/.local/bin"
systemd_dir="$config_home/systemd/user"

if [ ! -d /usr/share/quickshell/dms ]; then
    echo "DMS runtime not found at /usr/share/quickshell/dms" >&2
    exit 1
fi

install -d "$quickshell_dir" "$bin_dir" "$systemd_dir"
install -Dm755 "$repo_root/bin/dankosd" "$bin_dir/dankosd"
ln -sfn "$bin_dir/dankosd" "$bin_dir/dms-ddc-osd"
install -Dm644 "$repo_root/qml/shell.qml" "$quickshell_dir/shell.qml"
install -Dm644 "$repo_root/qml/LevelOSD.qml" "$quickshell_dir/LevelOSD.qml"
install -Dm644 "$repo_root/qml/DdcOsdState.qml" "$quickshell_dir/DdcOsdState.qml"

for name in Common Widgets Services Modules Modals assets; do
    ln -sfn "/usr/share/quickshell/dms/$name" "$quickshell_dir/$name"
done

install -Dm644 "$repo_root/systemd/dms-ddc-osd.service" "$systemd_dir/dms-ddc-osd.service"

systemctl --user daemon-reload
systemctl --user enable --now dms-ddc-osd.service

echo "Installed core files to $quickshell_dir"
echo "Installed command to $bin_dir/dankosd"
echo "Installed compatibility alias to $bin_dir/dms-ddc-osd"
echo "Service dms-ddc-osd.service is enabled"

echo
echo "Optional ddcfast integration:"
echo "  install -Dm755 $repo_root/integrations/ddcfast_osd.sh ${config_home}/hypr/dms/ddcfast_osd.sh"
echo "  update your compositor binds from examples/hyprland/binds.conf"
