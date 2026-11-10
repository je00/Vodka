import QtQuick 2.12
import MyModules 1.0
import "CurveMath.js" as CurveMath

// VOFA+ / Vodka custom widget: a lightweight viewer for up to three 3-D trajectories.
// Each enabled XYZ group is read together on sys_manager.need_update().
ResizableRectangle {
    id: root

    property string path: "curve3d"

    // The trail is deliberately a ring buffer.  It is runtime state and is not
    // persisted in the dashboard context; use the menu to choose its capacity.
    property var trail: CurveMath.createBuffer(2000)
    property var trail2: CurveMath.createBuffer(2000)
    property var trail3: CurveMath.createBuffer(2000)
    property int curveCount: 1
    property bool initialized: false
    readonly property var curveColors: ["#59dce5", "#ffb45b", "#f28cdb"]
    property var curveSizes: [0, 0, 0]
    property var curveSamples: ["", "", ""]
    property var curveBound: [false, false, false]
    property int historyCapacity: 2000
    property bool paused: false
    property bool autoFit: true
    property bool showGrid: true
    property bool dragging: false
    property real lastMouseX: 0
    property real lastMouseY: 0
    property int displayedCount: 0
    property bool bound: curveBound[0] || (curveCount > 1 && curveBound[1]) || (curveCount > 2 && curveBound[2])
    property real viewYaw: -45
    property real viewPitch: 25
    property real viewZoom: 1.0
    property real viewPanX: 0
    property real viewPanY: 0

    // viewSpan is the world-space diameter shown by the square viewport.
    property real viewSpan: 2
    property real viewCenterX: 0
    property real viewCenterY: 0
    property real viewCenterZ: 0

    onPausedChanged: markAllBreaks()
    onCurveCountChanged: {
        if (initialized) {
            markAllBreaks();
            refreshStats();
            if (autoFit) fitToData(false);
            else canvas.requestPaint();
        }
    }

    function buffers() { return [trail, trail2, trail3]; }
    function axisMenus() {
        return [[x_menu, y_menu, z_menu], [x2_menu, y2_menu, z2_menu], [x3_menu, y3_menu, z3_menu]];
    }
    function activeBuffers() { return buffers().slice(0, curveCount); }
    function renderEntries() {
        var all = buffers(), result = [];
        for (var i = 0; i < curveCount; ++i)
            result.push({buffer: all[i], color: curveColors[i]});
        return result;
    }
    function markAllBreaks() {
        var all = buffers();
        for (var i = 0; i < all.length; ++i)
            CurveMath.markBreak(all[i]);
    }
    function setCurveCount(value) {
        curveCount = Math.max(1, Math.min(3, Math.floor(value)));
    }
    function refreshStats() {
        var all = buffers(), menus = axisMenus(), sizes = [], boundStates = [];
        var total = 0;
        for (var i = 0; i < 3; ++i) {
            sizes.push(all[i].size);
            boundStates.push(!!(menus[i][0].bind_obj && menus[i][1].bind_obj && menus[i][2].bind_obj));
            if (i < curveCount) total += all[i].size;
        }
        curveSizes = sizes;
        curveBound = boundStates;
        displayedCount = total;
    }

    // Lazy references are used by VOFA+'s context restore helper.
    property Item ref: Loader {
        active: false
        sourceComponent: Component {
            Item {
                property var ref_x_menu: x_menu
                property var ref_y_menu: y_menu
                property var ref_z_menu: z_menu
                property var ref_x2_menu: x2_menu
                property var ref_y2_menu: y2_menu
                property var ref_z2_menu: z2_menu
                property var ref_x3_menu: x3_menu
                property var ref_y3_menu: y3_menu
                property var ref_z3_menu: z3_menu
            }
        }
    }

    width: g_settings.applyHScale(480)
    height: g_settings.applyVScale(380)
    minimumWidth: g_settings.applyHScale(300)
    minimumHeight: g_settings.applyVScale(240)
    color: "transparent"
    border.width: hovered ? g_settings.applyHScale(1) : 0
    border.color: "#59dce5"

    function currentView() {
        return {
            cx: viewCenterX,
            cy: viewCenterY,
            cz: viewCenterZ,
            span: viewSpan,
            width: canvas.width,
            height: canvas.height,
            yaw: viewYaw,
            pitch: viewPitch,
            zoom: viewZoom,
            panX: viewPanX,
            panY: viewPanY
        };
    }

    function fitToData(resetNavigation) {
        var b = CurveMath.boundsMany(activeBuffers());
        viewCenterX = b.cx;
        viewCenterY = b.cy;
        viewCenterZ = b.cz;
        // Leave a small margin around the extrema. bounds() supplies a default
        // span for an empty or single-point trail.
        viewSpan = Math.min(Number.MAX_VALUE, b.span * 1.25);
        if (!isFinite(viewSpan) || viewSpan <= 0)
            viewSpan = Number.MAX_VALUE;
        if (resetNavigation) {
            viewZoom = 1.0;
            viewPanX = 0;
            viewPanY = 0;
        }
        canvas.requestPaint();
    }

    function resetView() {
        viewYaw = -45;
        viewPitch = 25;
        fitToData(true);
    }

    function bindingChanged(index) {
        if (!initialized) return;
        var all = buffers(), texts = curveSamples.slice(0);
        CurveMath.clearBuffer(all[index]);
        CurveMath.markBreak(all[index]);
        texts[index] = "";
        curveSamples = texts;
        refreshStats();
        if (autoFit) fitToData(false);
        else canvas.requestPaint();
    }

    function clearTrail() {
        var all = buffers();
        for (var i = 0; i < all.length; ++i) {
            CurveMath.clearBuffer(all[i]);
            CurveMath.markBreak(all[i]);
        }
        curveSamples = ["", "", ""];
        refreshStats();
        if (autoFit) fitToData(true);
        else canvas.requestPaint();
    }

    function setHistoryCapacity(value) {
        var all = buffers();
        for (var i = 0; i < all.length; ++i)
            CurveMath.setCapacity(all[i], value);
        historyCapacity = all[0].capacity;
        refreshStats();
        if (autoFit) fitToData(false);
        else canvas.requestPaint();
    }

    function acceptSample() {
        if (paused) return;
        var all = buffers(), menus = axisMenus(), texts = curveSamples.slice(0);
        var added = false;
        // Each trajectory has independent bindings and history. A missing or
        // invalid group never blocks the other groups in this host refresh.
        for (var i = 0; i < curveCount; ++i) {
            var group = menus[i];
            if (!group[0].bind_obj || !group[1].bind_obj || !group[2].bind_obj) {
                CurveMath.markBreak(all[i]);
                continue;
            }
            var x = Number(group[0].bind_obj.value);
            var y = Number(group[1].bind_obj.value);
            var z = Number(group[2].bind_obj.value);
            if (!isFinite(x) || !isFinite(y) || !isFinite(z)) {
                CurveMath.markBreak(all[i]);
                continue;
            }
            if (CurveMath.append(all[i], x, y, z)) added = true;
            texts[i] = "X " + x.toPrecision(5) + "   Y " + y.toPrecision(5) + "   Z " + z.toPrecision(5);
        }
        curveSamples = texts;
        refreshStats();
        if (added && autoFit) fitToData(false);
        else if (added) canvas.requestPaint();
    }

    MyMenu {
        id: menu

        DeleteMenuItem { target: root }

        MyMenu {
            title: qsTr("显示轨迹数") + ": " + curveCount
            MyMenuItem { text: (curveCount === 1 ? "● " : "") + qsTr("1 条轨迹"); onTriggered: setCurveCount(1) }
            MyMenuItem { text: (curveCount === 2 ? "● " : "") + qsTr("2 条轨迹"); onTriggered: setCurveCount(2) }
            MyMenuItem { text: (curveCount === 3 ? "● " : "") + qsTr("3 条轨迹"); onTriggered: setCurveCount(3) }
        }
        MyMenu {
            title: qsTr("轨迹 1 · 青色")
            ChMenu {
                id: x_menu
                title: "X" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#ff5b65"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(0)
            }
            ChMenu {
                id: y_menu
                title: "Y" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#63df78"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(0)
            }
            ChMenu {
                id: z_menu
                title: "Z" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#59a8ff"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(0)
            }
        }
        MyMenu {
            title: qsTr("轨迹 2 · 橙色")
            ChMenu {
                id: x2_menu
                title: "X" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#ff5b65"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(1)
            }
            ChMenu {
                id: y2_menu
                title: "Y" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#63df78"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(1)
            }
            ChMenu {
                id: z2_menu
                title: "Z" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#59a8ff"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(1)
            }
        }
        MyMenu {
            title: qsTr("轨迹 3 · 粉色")
            ChMenu {
                id: x3_menu
                title: "X" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#ff5b65"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(2)
            }
            ChMenu {
                id: y3_menu
                title: "Y" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#63df78"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(2)
            }
            ChMenu {
                id: z3_menu
                title: "Z" + (bind_obj ? " → " + bind_obj.name : "")
                color: "#59a8ff"
                checked: bind_obj
                onBind_objChanged: root.bindingChanged(2)
            }
        }

        MyMenuSeparator {}

        MyMenuItem {
            text: paused ? qsTr("继续采样") : qsTr("暂停采样")
            onTriggered: {
                paused = !paused;
                canvas.requestPaint();
            }
        }
        MyMenuItem {
            text: showGrid ? qsTr("隐藏网格") : qsTr("显示网格")
            onTriggered: {
                showGrid = !showGrid;
                canvas.requestPaint();
            }
        }
        MyMenuItem {
            text: autoFit ? qsTr("关闭自动适配") : qsTr("开启自动适配")
            onTriggered: {
                autoFit = !autoFit;
                if (autoFit)
                    fitToData(true);
                else
                    canvas.requestPaint();
            }
        }
        MyMenuItem {
            text: qsTr("适配当前轨迹")
            onTriggered: fitToData(true)
        }
        MyMenuItem {
            text: qsTr("恢复默认视角")
            onTriggered: resetView()
        }
        MyMenuItem {
            text: "XY"
            onTriggered: { viewYaw = 0; viewPitch = 90; fitToData(true); }
        }
        MyMenuItem {
            text: "XZ"
            onTriggered: { viewYaw = 0; viewPitch = 0; fitToData(true); }
        }
        MyMenuItem {
            text: "YZ"
            onTriggered: { viewYaw = -90; viewPitch = 0; fitToData(true); }
        }
        MyMenuItem {
            text: qsTr("清空全部轨迹")
            onTriggered: clearTrail()
        }
        MyMenuItem {
            text: qsTr("每条轨迹点数: ") + historyCapacity
            onTriggered: {
                if (historyCapacity === 500)
                    setHistoryCapacity(2000);
                else if (historyCapacity === 2000)
                    setHistoryCapacity(10000);
                else
                    setHistoryCapacity(500);
            }
        }
    }

    Connections {
        target: root.mouse
        onClicked: {
            if (mouse.button === Qt.RightButton)
                menu.popup();
        }
    }

    Connections {
        target: sys_manager
        onNeed_update: root.acceptSample()
        // Some host builds also expose connectedChanged.  The documented
        // need_update signal remains the only sample source.
        ignoreUnknownSignals: true
        onConnectedChanged: root.markAllBreaks()
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.margins: g_settings.applyHScale(2)
        anchors.topMargin: g_settings.applyVScale(62)
        anchors.bottomMargin: g_settings.applyVScale(25 + curveCount * 16)
        renderTarget: Canvas.Image
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            CurveMath.renderManyCanvas(ctx, renderEntries(), currentView(), { grid: showGrid });
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        MouseArea {
            id: navigation
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: true

            onPressed: {
                if (mouse.button === Qt.RightButton) {
                    menu.popup();
                    return;
                }
                root.dragging = true;
                root.lastMouseX = mouse.x;
                root.lastMouseY = mouse.y;
            }
            onReleased: root.dragging = false
            onCanceled: root.dragging = false
            onPositionChanged: {
                if (!root.dragging)
                    return;
                var dx = mouse.x - root.lastMouseX;
                var dy = mouse.y - root.lastMouseY;
                if ((mouse.buttons & Qt.MiddleButton) || (mouse.modifiers & Qt.ShiftModifier)) {
                    root.autoFit = false;
                    root.viewPanX += dx;
                    root.viewPanY += dy;
                } else {
                    root.viewYaw = (root.viewYaw + dx * 0.6) % 360;
                    root.viewPitch = Math.max(-90, Math.min(90, root.viewPitch - dy * 0.5));
                }
                root.lastMouseX = mouse.x;
                root.lastMouseY = mouse.y;
                canvas.requestPaint();
            }
            onWheel: {
                if (wheel.angleDelta.y === 0)
                    return;
                root.autoFit = false;
                root.viewZoom *= wheel.angleDelta.y > 0 ? 1.12 : 0.89;
                root.viewZoom = Math.max(0.15, Math.min(20, root.viewZoom));
                canvas.requestPaint();
            }
            onDoubleClicked: root.resetView()
        }
    }

    Rectangle {
        anchors.fill: parent
        z: -1
        color: "#101b2b"
        radius: 4
    }
    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: g_settings.applyHScale(10)
        color: "#e8f3fb"
        font.family: "Microsoft YaHei UI"
        font.pixelSize: g_settings.applyHScale(13)
        text: "CURVE 3D    " + curveCount + qsTr(" 条轨迹")
              + (paused ? qsTr("  · 已暂停") : "")
              + (autoFit ? qsTr("  · 自动适配") : "")
        elide: Text.ElideRight
    }
    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: g_settings.applyHScale(10)
        anchors.topMargin: g_settings.applyVScale(33)
        spacing: g_settings.applyHScale(12)
        Repeater {
            model: root.curveCount
            Text {
                color: root.curveColors[index]
                font.family: "Microsoft YaHei UI"
                font.pixelSize: g_settings.applyHScale(11)
                text: (index + 1) + ": " + root.curveSizes[index] + "/" + root.historyCapacity
                      + (root.curveBound[index] ? "" : qsTr(" 未绑定"))
            }
        }
    }
    Text {
        anchors.centerIn: canvas
        visible: displayedCount === 0
        color: "#d5e9f7"
        font.family: "Microsoft YaHei UI"
        text: bound ? qsTr("等待 XYZ 数据刷新") : qsTr("右键 → 选择轨迹数，并为各轨迹绑定 X / Y / Z")
        font.pixelSize: g_settings.applyHScale(11)
        width: canvas.width - 16
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: g_settings.applyHScale(8)
        spacing: g_settings.applyVScale(2)
        Repeater {
            model: root.curveCount
            Text {
                width: parent.width
                color: root.curveColors[index]
                font.family: "Microsoft YaHei UI"
                font.pixelSize: g_settings.applyHScale(10)
                text: (index + 1) + "  " + (root.curveSamples[index] || qsTr("等待本轨迹数据"))
                elide: Text.ElideRight
            }
        }
        Text {
            width: parent.width
            color: "#b2c8dc"
            font.family: "Microsoft YaHei UI"
            font.pixelSize: g_settings.applyHScale(10)
            text: qsTr("左键旋转 · 滚轮缩放 · Shift+左键平移 · 双击适配 · 右键设置")
            elide: Text.ElideRight
        }
    }

    Component.onCompleted: {
        initialized = true;
        refreshStats();
        fitToData(false);
    }

    function get_widget_ctx() {
        return {
            'path': path,
            'ctx': {
                '.': {
                    'ctx': get_ctx(),
                    'viewYaw': viewYaw,
                    'viewPitch': viewPitch,
                    'viewZoom': viewZoom,
                    'viewPanX': viewPanX,
                    'viewPanY': viewPanY,
                    'viewSpan': viewSpan,
                    'viewCenterX': viewCenterX,
                    'viewCenterY': viewCenterY,
                    'viewCenterZ': viewCenterZ,
                    'showGrid': showGrid,
                    'autoFit': autoFit,
                    'historyCapacity': historyCapacity,
                    'curveCount': curveCount
                },
                'x_menu': { 'ctx': x_menu.get_ctx() },
                'y_menu': { 'ctx': y_menu.get_ctx() },
                'z_menu': { 'ctx': z_menu.get_ctx() },
                'x2_menu': { 'ctx': x2_menu.get_ctx() },
                'y2_menu': { 'ctx': y2_menu.get_ctx() },
                'z2_menu': { 'ctx': z2_menu.get_ctx() },
                'x3_menu': { 'ctx': x3_menu.get_ctx() },
                'y3_menu': { 'ctx': y3_menu.get_ctx() },
                'z3_menu': { 'ctx': z3_menu.get_ctx() }
            }
        };
    }

    function set_widget_ctx(ctx) {
        __set_ctx__(root, ctx.ctx, ref);
        setHistoryCapacity(historyCapacity);
        markAllBreaks();
        refreshStats();
        canvas.requestPaint();
    }
}
