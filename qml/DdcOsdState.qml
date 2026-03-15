import QtQuick

QtObject {
    id: root

    property int brightnessValue: 0
    property int contrastValue: 0

    signal brightnessRequested()
    signal contrastRequested()

    function clampPercent(value) {
        return Math.max(0, Math.min(100, value));
    }

    function parsePercent(raw) {
        const value = parseInt(raw);
        if (isNaN(value))
            return null;
        return clampPercent(value);
    }

    function showBrightness(raw) {
        const value = parsePercent(raw);
        if (value === null)
            return "Invalid brightness value: " + raw;
        brightnessValue = value;
        brightnessRequested();
        return "Brightness OSD " + value + "%";
    }

    function showContrast(raw) {
        const value = parsePercent(raw);
        if (value === null)
            return "Invalid contrast value: " + raw;
        contrastValue = value;
        contrastRequested();
        return "Contrast OSD " + value + "%";
    }

    function showLevel(kind, raw) {
        switch ((kind || "").toLowerCase()) {
        case "brightness":
            return showBrightness(raw);
        case "contrast":
            return showContrast(raw);
        default:
            return "Unknown OSD kind: " + kind;
        }
    }

    function status() {
        return JSON.stringify({
            "brightness": brightnessValue,
            "contrast": contrastValue
        });
    }
}
