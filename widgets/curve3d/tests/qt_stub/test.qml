import QtQuick 2.12
import "../../CurveMath.js" as CurveMath

// Only a test host: these objects emulate the documented channel interface.
Item {
    id: testRoot
    width: 960
    height: 760
    property var widget: loader.item
    property var channels: [c0, c1, c2, c3, c4, c5, c6, c7, c8]
    QtObject { id: c0; property string name: "CH0"; property real value: 0 }
    QtObject { id: c1; property string name: "CH1"; property real value: 0 }
    QtObject { id: c2; property string name: "CH2"; property real value: 0 }
    QtObject { id: c3; property string name: "CH3"; property real value: 0 }
    QtObject { id: c4; property string name: "CH4"; property real value: 0 }
    QtObject { id: c5; property string name: "CH5"; property real value: 0 }
    QtObject { id: c6; property string name: "CH6"; property real value: 0 }
    QtObject { id: c7; property string name: "CH7"; property real value: 0 }
    QtObject { id: c8; property string name: "CH8"; property real value: 0 }

    function channel(index) {
        return index >= 0 && index < channels.length ? channels[index] : null;
    }
    function indexOfChannel(object) {
        for (var index = 0; index < channels.length; ++index)
            if (channels[index] === object) return index;
        return -1;
    }

    function menuFor(group, axis) {
        widget.ref.active = true;
        return widget.ref.item["ref_" + "xyz"[axis] + (group ? group + 1 : "") + "_menu"];
    }
    function bindCurve(group) {
        for (var axis = 0; axis < 3; ++axis)
            menuFor(group, axis).bind_obj = channels[group * 3 + axis];
    }
    function bindChannels() {
        for (var group = 0; group < 3; ++group) bindCurve(group);
    }
    function unbindAxis(group, axis) { menuFor(group, axis).bind_obj = null; }
    function sampleCurve(group, x, y, z) {
        channels[group * 3].value = x;
        channels[group * 3 + 1].value = y;
        channels[group * 3 + 2].value = z;
    }
    function bufferState() {
        var all = widget.buffers(), result = [];
        for (var group = 0; group < 3; ++group) {
            var buffer = all[group];
            result.push({size: buffer.size, total: buffer.total,
                         capacity: buffer.capacity,
                         first: CurveMath.pointAt(buffer, 0),
                         last: CurveMath.pointAt(buffer, buffer.size - 1)});
        }
        return JSON.stringify(result);
    }
    function boundNames() {
        var result = [];
        for (var group = 0; group < 3; ++group)
            for (var axis = 0; axis < 3; ++axis) {
                var obj = menuFor(group, axis).bind_obj;
                result.push(obj ? obj.name : null);
            }
        return JSON.stringify(result);
    }
    function reloadWidget() { loader.active = false; loader.active = true; }
    Loader {
        id: loader
        anchors.fill: parent
        source: "../../curve3d.qml"
    }
}
