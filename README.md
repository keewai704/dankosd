# dankosd

Standalone Quickshell OSD for external monitor brightness and contrast, styled to match DankMaterialShell (DMS).

`dankosd` does not patch DMS itself. It runs as a separate Quickshell config, reuses DMS theme/settings/runtime components, and exposes a tiny IPC surface for monitor OSD updates.

## What It Does

- shows a DMS-styled OSD for brightness and contrast
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

Show brightness or contrast OSD manually:

```bash
dankosd brightness 42
dankosd contrast 37
```

Generic entrypoint:

```bash
dankosd contrast 25
dankosd show brightness 50
dankosd settings 75
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
dms-ddc-osd brightness 42
```

## Repository Layout

- [`qml/`](./qml): Quickshell config and OSD components
- [`bin/dankosd`](./bin/dankosd): CLI entrypoint
- [`systemd/dms-ddc-osd.service`](./systemd/dms-ddc-osd.service): user service example
- [`systemd/dankosd.service`](./systemd/dankosd.service): system package user service
- [`integrations/ddcfast_osd.sh`](./integrations/ddcfast_osd.sh): `ddcfast` bridge
- [`examples/hyprland/binds.conf`](./examples/hyprland/binds.conf): sample Hyprland binds
- [`scripts/install.sh`](./scripts/install.sh): local installer for this machine layout
- [`scripts/stage-system.sh`](./scripts/stage-system.sh): staging helper for distro packages
- [`packaging/arch/PKGBUILD`](./packaging/arch/PKGBUILD): Arch package definition
- [`scripts/build-deb.sh`](./scripts/build-deb.sh): Ubuntu/Debian package builder
- [`flake.nix`](./flake.nix): Nix flake package entrypoint

## Install

```bash
./scripts/install.sh
```

That installs:

- `~/.local/bin/dankosd`
- `~/.local/bin/dms-ddc-osd` as a compatibility alias
- `~/.config/quickshell/ddc-osd/`
- `~/.config/systemd/user/dms-ddc-osd.service`

## ddcfast Integration

Install the bridge script:

```bash
install -Dm755 integrations/ddcfast_osd.sh ~/.config/hypr/dms/ddcfast_osd.sh
```

Then add binds similar to [`examples/hyprland/binds.conf`](./examples/hyprland/binds.conf).

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
