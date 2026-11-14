// User step: design-system/boards/InstallUser.dc.html.
import QtQuick
import io.calamares.core 1.0
import io.calamares.ui 1.0
import "components"

DPage {
    id: page

    Column {
        width: parent.width
        spacing: 24

        Column {
            width: parent.width
            spacing: 8
            DHeading { width: parent.width; text: "Create your account" }
            DBody { width: parent.width; text: "This account can change system settings and install software." }
        }

        DField {
            width: parent.width
            label: "Full name"
            DInput {
                enabled: config.isEditable("fullName")
                text: config.fullName
                onTextChanged: config.setFullName(text)
                focus: true
            }
        }
        DField {
            id: login
            width: parent.width
            reserveMessage: true
            label: "User name"
            error: config.loginNameStatus !== ""
            message: config.loginName === "" ? "" : error ? "[Error: " + config.loginNameStatus + "]" : "[ OK ]"
            DInput {
                enabled: config.isEditable("loginName")
                error: login.error
                text: config.loginName
                onTextChanged: if (text !== config.loginName) config.setLoginName(text)
                validator: RegularExpressionValidator { regularExpression: /[a-z_][a-z0-9_-]*[$]?$/ }
            }
        }
        DField {
            width: parent.width
            label: "Password"
            reserveMessage: true
            // Calamares' own checks (libpwquality); Next follows these.
            // Only once both fields agree: before that, Calamares' verdict is
            // just "do not match", which the repeat field already says.
            readonly property bool rejected: page.matched && config.userPasswordValidity === 2
            error: rejected
            message: page.matched && config.userPasswordValidity > 0
                     ? "[Error: " + config.userPasswordMessage.replace(/[.!]$/, "") + "]" : ""
            DInput {
                id: pw
                error: parent.parent.rejected
                echoMode: TextInput.Password
                passwordCharacter: "•"
                text: config.userPassword
                onTextChanged: config.setUserPassword(text)
            }
        }
        DField {
            id: repeat
            width: parent.width
            label: "Repeat password"
            reserveMessage: true
            readonly property bool differs: pw2.text !== "" && pw2.text !== pw.text
            error: differs
            message: differs ? "[Error: passwords differ]" : ""
            DInput {
                id: pw2
                error: repeat.error
                echoMode: TextInput.Password
                passwordCharacter: "•"
                text: config.userPasswordSecondary
                onTextChanged: config.setUserPasswordSecondary(text)
            }
        }
    }

    aside: Column {
        width: parent.width
        spacing: 24

        DField {
            id: host
            width: parent.width
            topPadding: 76
            label: "Computer name"
            reserveMessage: true
            error: config.hostnameStatus !== ""
            message: error ? "[Error: " + config.hostnameStatus + "]"
                   : config.hostname !== "" ? "Shown on the network as " + config.hostname + ".local" : ""
            DInput {
                error: host.error
                text: config.hostname
                onTextChanged: if (text !== config.hostname) config.setHostName(text)
                validator: RegularExpressionValidator { regularExpression: /[a-zA-Z0-9][-a-zA-Z0-9_]+/ }
            }
        }

        Column {
            width: parent.width
            spacing: 8
            readonly property var strength: page.rate(pw.text, page.matched ? config.userPasswordValidity : 0)
            DLabel { text: "Password strength" }
            DSeg {
                width: parent.width
                height: 4
                count: 20
                lit: parent.strength.lit
                tone: parent.strength.tone
            }
            Item {
                width: parent.width
                height: Math.max(rating.height, hint.height)
                DStatus { id: rating; visible: pw.text !== ""; text: "[" + parent.parent.strength.word + "]" }
                Text {
                    id: hint
                    anchors.right: parent.right
                    anchors.baseline: rating.baseline
                    text: parent.parent.strength.hint
                    font.family: T.mono
                    font.pixelSize: 12
                    font.letterSpacing: 12 * 0.04
                    color: T.textSecondary
                }
            }
        }

        Column {
            width: parent.width
            DCheck {
                text: "Log in automatically"
                checked: config.doAutoLogin
                onToggled: config.setAutoLogin(!checked)
            }
            // Only when the install sets a root password (Debian's default
            // leaves root locked and uses sudo, so this stays hidden).
            DCheck {
                visible: config.writeRootPassword
                text: "Use the same password for administrator tasks"
                checked: config.reuseUserPasswordForRoot
                onToggled: config.setReuseUserPasswordForRoot(!checked)
            }
        }
    }

    readonly property bool matched: pw.text !== "" && pw2.text === pw.text

    // A plain length-and-variety score for the meter. Calamares does its own
    // checks (the Next button follows those); this only guides.
    function rate(p, validity) {
        if (p.length === 0) return { lit: 0, tone: "", word: "None", hint: "" };
        if (validity === 2)
            return { lit: 3, tone: "bad", word: "Weak", hint: "Avoid dictionary words" };
        var classes = 0;
        if (/[a-z]/.test(p)) classes++;
        if (/[A-Z]/.test(p)) classes++;
        if (/[0-9]/.test(p)) classes++;
        if (/[^a-zA-Z0-9]/.test(p)) classes++;
        var score = Math.min(20, Math.round(p.length * 0.75 + (classes - 1) * 2.5));
        var missing = Math.max(0, 14 - p.length);
        if (score < 7)
            return { lit: Math.max(2, score), tone: "bad", word: "Weak", hint: "Use " + Math.max(missing, 4) + " more characters" };
        if (score < 14) {
            var tip = classes < 4 ? "Add a symbol or " + Math.max(missing, 2) + " more characters" : "Add " + Math.max(missing, 2) + " more characters";
            return { lit: score, tone: "warn", word: "Fair", hint: tip };
        }
        return { lit: score, tone: "good", word: "Strong", hint: "" };
    }

    function onActivate() {}
    function onLeave() {}
}
