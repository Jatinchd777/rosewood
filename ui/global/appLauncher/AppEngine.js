function calculate(expr) {
    try {
        let sanitized = expr.replace(/[^0-9\+\-\*\/\(\)\.\s]/g, '');
        if (!sanitized.trim()) return "";
        let result = Function('"use strict";return (' + sanitized + ')')();
        return result !== undefined ? result.toString() : "";
    } catch (e) {
        return "...";
    }
}

function parseAppLine(line) {
    if (!line || line.trim() === "") return null;
    let parts = line.split("|");
    if (parts.length < 2) return null;

    let name = parts[0].trim();
    let execCmd = parts[1].trim();
    let icon = parts[2] ? parts[2].trim() : "";

    if (icon === "") {
        icon = "application-x-executable"; 
    }

    return {
        name: name,
        execCmd: execCmd,
        icon: icon
    };
}
