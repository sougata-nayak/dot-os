// Location step. No board of its own; the Installer board's grammar: region
// and zone pickers on the left, language and formats on the right, with the
// resulting settings as list rows.
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
            DHeading { width: parent.width; text: "Where are you?" }
            DBody { width: parent.width; text: "Sets the clock and time zone. Language and formats follow, and you can change them." }
        }

        DField {
            width: parent.width
            label: "Region"
            DSelect {
                id: region
                model: config.regionModel
                textRole: "name"
                valueRole: "key"
                onActivated: {
                    config.regionalZonesModel.region = currentValue;
                    zone.currentIndex = -1;
                }
            }
        }
        DField {
            width: parent.width
            label: "Time zone"
            DSelect {
                id: zone
                model: config.regionalZonesModel
                textRole: "name"
                valueRole: "key"
                onActivated: config.setCurrentLocation(region.currentValue, currentValue)
            }
        }
    }

    aside: Column {
        width: parent.width
        spacing: 24

        DField {
            width: parent.width
            topPadding: 76
            label: "Language"
            DSelect {
                id: lang
                model: config.supportedLocales
                onActivated: config.currentLanguageCode = currentText
            }
        }
        DField {
            width: parent.width
            label: "Dates, numbers and currency"
            DSelect {
                id: lc
                model: config.supportedLocales
                onActivated: config.currentLCCode = currentText
            }
        }
        Column {
            width: parent.width
            DLabel { text: "You get"; bottomPadding: 4 }
            DRow { label: "Time zone"; value: config.currentTimezoneCode || config.currentTimezoneName }
            DRow { label: "Language"; value: config.currentLanguageCode }
            DRow { label: "Formats"; value: config.currentLCCode || config.currentLanguageCode; last: true }
        }
    }

    // Point the pickers at whatever Calamares chose (GeoIP or the default).
    function sync() {
        var loc = config.currentLocation;
        if (loc) {
            region.currentIndex = region.indexOfValue(loc.region);
            config.regionalZonesModel.region = loc.region;
            zone.currentIndex = zone.indexOfValue(loc.zone);
        }
        lang.currentIndex = lang.find(config.currentLanguageCode);
        lc.currentIndex = lc.find(config.currentLCCode || config.currentLanguageCode);
    }
    Connections {
        target: config
        function onCurrentLocationChanged() { page.sync(); }
        function onCurrentLanguageCodeChanged() { lang.currentIndex = lang.find(config.currentLanguageCode); }
        function onCurrentLCCodeChanged() { lc.currentIndex = lc.find(config.currentLCCode); }
    }
    function onActivate() { sync(); }
    function onLeave() {}
}
