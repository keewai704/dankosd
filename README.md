# dankosd

Standalone Quickshell OSD for icon + level events, styled to match DankMaterialShell (DMS).

`dankosd` does not patch DMS itself. It runs as a separate Quickshell config, reuses DMS theme/settings/runtime components, and exposes a small IPC surface for generic OSD updates.

## What It Does

- shows a DMS-styled OSD for arbitrary icon + percentage events
- keeps `brightness` and `contrast` as convenience commands
- reads DMS settings so placement, spacing, radius, fonts, and colors stay consistent
- works as a separate service, so DMS does not need custom patches
- integrates with `ddcfast` for low-latency external monitor control

## Requirements

- DankMaterialShell installed at `/usr/share/quickshell/dms`
- Quickshell
- a compositor supported by your local DMS install
- optionally `ddcfast` if you want hardware brightness/contrast control tied to this OSD

DMS is MIT licensed. This project intentionally depends on its installed runtime modules instead of vendoring them.

## Commands

Generic entrypoint:

```bash
dankosd settings 75
dankosd volume_up 50
dankosd show contrast 25
```

Convenience commands:

```bash
dankosd brightness 42
dankosd contrast 37
```

Inspect current in-memory state:

```bash
dankosd status
```

Run the Quickshell config directly:

```bash
dankosd serve
```

Compatibility alias:

```bash
dms-ddc-osd settings 42
```

Config path resolution order:

1. `DANKOSD_CONFIG_PATH`
2. `~/.config/quickshell/ddc-osd`
3. `/usr/share/dankosd/qml`

## Repository Layout

- [`qml/`](./qml): Quickshell config and OSD components
- [`bin/dankosd`](./bin/dankosd): CLI entrypoint
- [`systemd/dms-ddc-osd.service`](./systemd/dms-ddc-osd.service): local user service example
- [`systemd/dankosd.service`](./systemd/dankosd.service): package-oriented user service
- [`integrations/ddcfast_osd.sh`](./integrations/ddcfast_osd.sh): `ddcfast` bridge
- [`examples/hyprland/binds.conf`](./examples/hyprland/binds.conf): sample Hyprland binds
- [`scripts/install.sh`](./scripts/install.sh): local installer for this machine layout
- [`scripts/stage-system.sh`](./scripts/stage-system.sh): staging helper for distro packages
- [`packaging/arch/PKGBUILD`](./packaging/arch/PKGBUILD): Arch package definition
- [`scripts/build-deb.sh`](./scripts/build-deb.sh): Ubuntu/Debian package builder
- [`flake.nix`](./flake.nix): Nix flake package entrypoint

## Install

### Local install

```bash
./scripts/install.sh
```

That installs:

- `~/.local/bin/dankosd`
- `~/.local/bin/dms-ddc-osd` as a compatibility alias
- `~/.config/quickshell/ddc-osd/`
- `~/.config/systemd/user/dms-ddc-osd.service`

That path is useful when you want to iterate on the repo directly.

### Package install

The packaged layout installs:

- `/usr/bin/dankosd`
- `/usr/bin/dms-ddc-osd`
- `/usr/share/dankosd/qml/`
- `/usr/lib/systemd/user/dankosd.service`
- `/usr/lib/systemd/user/dms-ddc-osd.service` as an alias to `dankosd.service`

After installing a distro package:

```bash
systemctl --user enable --now dankosd.service
```

## ddcfast Integration

Install the bridge script:

```bash
install -Dm755 integrations/ddcfast_osd.sh ~/.config/hypr/dms/ddcfast_osd.sh
```

Then add binds similar to [`examples/hyprland/binds.conf`](./examples/hyprland/binds.conf).

The bridge defaults to `/usr/bin/ddcfast` and `/usr/bin/dankosd`, and can be overridden with `DDCFAST_BIN` and `DANKOSD_BIN`.

The bridge script:

- sends the real hardware change through `ddcfast --async`
- computes the UI percentage that should be shown
- sends that percentage to `dankosd`
- supports both brightness and contrast
- respects brightness scaling such as `--scale 0.75`

## Packaging

Arch package:

```bash
./scripts/build-arch-package.sh
```

Ubuntu/Debian package:

```bash
./scripts/build-deb.sh
```

Nix package:

```bash
nix build .#dankosd
```

The system package installs the QML files under `/usr/share/dankosd/qml` and expects DMS to be available at `/usr/share/quickshell/dms` unless you override `DANKOSD_DMS_PATH`.

## Design Notes

The OSD itself is intentionally small:

- `qml/shell.qml` wires IPC and screen variants
- `qml/DdcOsdState.qml` holds the current icon/value pair and dispatches update signals
- `qml/LevelOSD.qml` renders a DMS-styled icon + level bar using `DankOSD`, `Theme`, and `SettingsData`

Because it imports DMS runtime modules from the installed system path, visual changes in DMS theme/settings are reflected automatically.

## License

MIT
