#!/bin/sh
set -eu

ddcfast_bin="${DDCFAST_BIN:-$HOME/.local/bin/ddcfast}"
osd_bin="${DANKOSD_BIN:-$HOME/.local/bin/dankosd}"
runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
state_json="${XDG_STATE_HOME:-$HOME/.local/state}/ddcfast/state.json"

usage() {
    echo "Usage: $0 {brightness|contrast} {+N|-N|N} --display <selector> [--scale <value>]" >&2
    exit 2
}

[ "$#" -ge 2 ] || usage
feature="$1"
value="$2"
shift 2

display=""
scale="1.0"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --display)
            [ "$#" -ge 2 ] || usage
            display="$2"
            shift 2
            ;;
        --scale)
            [ "$#" -ge 2 ] || usage
            scale="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

case "$feature" in
    brightness|contrast)
        ;;
    *)
        usage
        ;;
esac

[ -n "$display" ] || usage

sanitize_name() {
    printf '%s' "$1" | tr -c '[:alnum:]._-' '_'
}

effective_scale() {
    if [ "$feature" = "brightness" ]; then
        printf '%s\n' "$scale"
    else
        printf '1.0\n'
    fi
}

clamp_percent() {
    if [ "$1" -lt 0 ]; then
        echo 0
    elif [ "$1" -gt 100 ]; then
        echo 100
    else
        echo "$1"
    fi
}

state_key_for_display() {
    list_output="$($ddcfast_bin list 2>/dev/null || true)"
    serial="$(printf '%s\n' "$list_output" | awk -v selector="$display" '
        $1 == selector || index($1, selector) {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^serial:/) {
                    sub(/^serial:/, "", $i);
                    print tolower($i);
                    exit;
                }
            }
        }
    ')"
    [ -n "$serial" ] || return 1
    [ -f "$state_json" ] || return 1

    jq -r --arg serial "$serial" '
        .displays
        | to_entries[]
        | select((.key | ascii_downcase) | endswith(":" + $serial))
        | .key
        | halt
    ' "$state_json" 2>/dev/null
}

seed_from_persisted_state() {
    key="$(state_key_for_display || true)"
    [ -n "$key" ] || return 1

    raw="$(jq -r --arg key "$key" --arg feature "$feature" '.displays[$key][$feature].value // empty' "$state_json" 2>/dev/null)"
    max="$(jq -r --arg key "$key" --arg feature "$feature" '.displays[$key][$feature].max // empty' "$state_json" 2>/dev/null)"
    [ -n "$raw" ] || return 1
    [ -n "$max" ] || return 1
    [ "$max" -gt 0 ] 2>/dev/null || return 1

    scale_value="$(effective_scale)"
    scaled_max="$(awk -v max="$max" -v scale="$scale_value" 'BEGIN {
        value = int((max * scale) + 0.5);
        if (value < 1) value = 1;
        if (value > max) value = max;
        print value;
    }')"
    [ "$scaled_max" -gt 0 ] 2>/dev/null || return 1

    awk -v raw="$raw" -v scaled_max="$scaled_max" 'BEGIN {
        value = int(((raw * 100.0) / scaled_max) + 0.5);
        if (value < 0) value = 0;
        if (value > 100) value = 100;
        print value;
    }'
}

seed_from_sync_probe() {
    if [ "$feature" = "brightness" ]; then
        probe_output="$($ddcfast_bin "$feature" +0 --display "$display" --scale "$scale" 2>/dev/null || true)"
    else
        probe_output="$($ddcfast_bin "$feature" +0 --display "$display" 2>/dev/null || true)"
    fi

    raw="$(printf '%s\n' "$probe_output" | sed -n "s/.*$feature set to \\([0-9][0-9]*\\)\\/\\([0-9][0-9]*\\).*/\\1/p" | head -n1)"
    max="$(printf '%s\n' "$probe_output" | sed -n "s/.*$feature set to \\([0-9][0-9]*\\)\\/\\([0-9][0-9]*\\).*/\\2/p" | head -n1)"
    [ -n "$raw" ] || return 1
    [ -n "$max" ] || return 1

    scale_value="$(effective_scale)"
    scaled_max="$(awk -v max="$max" -v scale="$scale_value" 'BEGIN {
        value = int((max * scale) + 0.5);
        if (value < 1) value = 1;
        if (value > max) value = max;
        print value;
    }')"

    awk -v raw="$raw" -v scaled_max="$scaled_max" 'BEGIN {
        value = int(((raw * 100.0) / scaled_max) + 0.5);
        if (value < 0) value = 0;
        if (value > 100) value = 100;
        print value;
    }'
}

cache_file="$runtime_dir/ddcfast-$feature-osd.$(sanitize_name "$display").state"

current=""
if [ -f "$cache_file" ]; then
    current="$(cat "$cache_file" 2>/dev/null || true)"
fi
case "$current" in
    ''|*[!0-9]*)
        current=""
        ;;
esac
if [ -z "$current" ]; then
    current="$(seed_from_persisted_state || true)"
fi
if [ -z "$current" ]; then
    current="$(seed_from_sync_probe || true)"
fi
if [ -z "$current" ]; then
    current="50"
fi

case "$value" in
    +*|-*)
        target=$((current + value))
        ;;
    *)
        target="$value"
        ;;
esac

case "$target" in
    ''|*[!0-9-]*)
        echo "invalid $feature value: $value" >&2
        exit 1
        ;;
esac

target="$(clamp_percent "$target")"
printf '%s\n' "$target" >"$cache_file"

if [ "$feature" = "brightness" ]; then
    "$ddcfast_bin" "$feature" "$value" --display "$display" --scale "$scale" --async >/dev/null
else
    "$ddcfast_bin" "$feature" "$value" --display "$display" --async >/dev/null
fi
"$osd_bin" "$feature" "$target" >/dev/null 2>&1 &
