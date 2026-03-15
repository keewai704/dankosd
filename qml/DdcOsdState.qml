import QtQuick

QtObject {
    id: root

    property string iconName: "brightness_medium"
    property int levelValue: 0

    signal showRequested()

    function clampPercent(value) {
        return Math.max(0, Math.min(100, value));
    }

    function parsePercent(raw) {
        const value = parseInt(raw);
        if (isNaN(value))
            return null;
        return clampPercent(value);
    }

    function resolveIcon(name) {
        switch ((name || "").toLowerCase()) {
        case "brightness":
            return "brightness_medium";
        case "contrast":
            return "contrast";
        default:
            return (name || "").trim();
        }
    }

    function showIcon(name, raw) {
        const resolvedIcon = resolveIcon(name);
        const value = parsePercent(raw);
        if (!resolvedIcon)
            return "Invalid icon name";
        if (value === null)
            return "Invalid OSD value: " + raw;
        iconName = resolvedIcon;
        levelValue = value;
        showRequested();
        return "OSD " + resolvedIcon + " " + value + "%";
    }

    function showBrightness(raw) {
        return showIcon("brightness", raw);
    }

    function showContrast(raw) {
        return showIcon("contrast", raw);
    }

    function showLevel(icon, raw) {
        return showIcon(icon, raw);
    }

    function status() {
        return JSON.stringify({
            "icon": iconName,
            "value": levelValue
        });
    }
}
