// .dot-select with the .dot-menu popup: outlined 8px box, mono 14px, chevron;
// the highlighted item is inverted.
import QtQuick
import QtQuick.Controls.Basic
import "."

ComboBox {
    id: c
    implicitHeight: T.controlMin
    width: parent ? parent.width : implicitWidth
    font.family: T.mono
    font.pixelSize: 14

    contentItem: Text {
        leftPadding: 16
        rightPadding: 40
        text: c.displayText
        font: c.font
        color: T.textPrimary
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Canvas {
        x: c.width - width - 12
        y: (c.height - height) / 2
        width: 16; height: 16
        onPaint: {
            var g = getContext("2d");
            g.reset();
            g.strokeStyle = T.textSecondary;
            g.lineWidth = 1.5;
            g.lineCap = "round";
            g.lineJoin = "round";
            g.beginPath();
            g.moveTo(4, 6); g.lineTo(8, 10); g.lineTo(12, 6);
            g.stroke();
        }
    }

    background: Rectangle {
        color: "transparent"
        radius: T.radiusCompact
        border.width: 1
        border.color: c.hovered || c.popup.visible || c.visualFocus ? T.textPrimary : T.borderVisible
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    delegate: ItemDelegate {
        id: d
        width: ListView.view ? ListView.view.width : c.width
        height: 36
        highlighted: c.highlightedIndex === index
        contentItem: Text {
            leftPadding: 12
            text: c.textRole ? (Array.isArray(c.model) ? modelData[c.textRole] : model[c.textRole]) : modelData
            font: c.font
            color: d.highlighted ? T.black : index === c.currentIndex ? T.textDisplay : T.textPrimary
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: T.radiusTechnical
            color: d.highlighted ? T.textDisplay : "transparent"
        }
    }

    popup: Popup {
        y: c.height + 4
        width: c.width
        implicitHeight: Math.min(contentItem.implicitHeight + 8, 36 * 8 + 8)
        padding: 4
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: c.popup.visible ? c.delegateModel : null
            currentIndex: c.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator {
                contentItem: Rectangle { implicitWidth: 2; color: T.borderVisible }
            }
        }
        background: Rectangle {
            color: T.surfaceRaised
            radius: T.radiusCompact
            border.width: 1
            border.color: T.borderVisible
        }
    }
}
