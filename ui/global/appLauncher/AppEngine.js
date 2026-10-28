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
