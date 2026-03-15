import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

ShellRoot {
    id: root

    readonly property var osdStateRef: osdState

    DdcOsdState {
        id: osdState
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: LevelOSD {
            modelData: item
            osdState: root.osdStateRef
        }
    }

    IpcHandler {
        target: "osd"

        function brightness(value: string): string {
            return osdState.showBrightness(value);
        }

        function contrast(value: string): string {
            return osdState.showContrast(value);
        }

        function level(kind: string, value: string): string {
            return osdState.showLevel(kind, value);
        }

        function status(): string {
            return osdState.status();
        }
    }
}
