"""Offscreen multi-trajectory checks using the actual shipped QML files.
Requires PyQt5. Host stubs are ONLY for tests, not for installation.
This verifies QML behavior, not a VOFA+ executable integration.
"""
import copy
import json
import math
import os
from pathlib import Path
import time

os.environ['QT_QPA_PLATFORM'] = 'offscreen'
os.environ['QT_QUICK_BACKEND'] = 'software'
if os.path.isdir('C:/Windows/Fonts'):
    os.environ['QT_QPA_FONTDIR'] = 'C:/Windows/Fonts'
from PyQt5.QtCore import QObject, QEvent, QUrl, pyqtSignal, pyqtSlot, qInstallMessageHandler
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQuick import QQuickView
PACKAGE_ROOT = Path(__file__).resolve().parents[1]
STUB_ROOT = PACKAGE_ROOT / 'tests/qt_stub'

class Settings(QObject):
    @pyqtSlot(float, result=float)
    def applyHScale(self, value): return value
    @pyqtSlot(float, result=float)
    def applyVScale(self, value): return value
class Manager(QObject):
    need_update = pyqtSignal()
    connectedChanged = pyqtSignal()
messages = []
def logger(kind, context, message):
    messages.append(message)
    print(message)
qInstallMessageHandler(logger)
app = QGuiApplication([])
view = QQuickView()
settings, manager = Settings(app), Manager(app)
view.engine().addImportPath(str(STUB_ROOT))
view.rootContext().setContextProperty('g_settings', settings)
view.rootContext().setContextProperty('sys_manager', manager)
view.setResizeMode(QQuickView.SizeRootObjectToView)
view.setSource(QUrl.fromLocalFile(str(STUB_ROOT / 'test.qml')))
assert view.status() == QQuickView.Ready, [e.toString() for e in view.errors()]
view.resize(960, 760)
view.show()
app.processEvents()
root = view.rootObject()
view.rootContext().setContextProperty('testChannelRegistry', root)
widget = root.property('widget')
assert widget is not None

def state(): return json.loads(root.bufferState())
def sizes(): return [buffer['size'] for buffer in state()]
def sample_tick(value):
    for group in range(3):
        root.sampleCurve(group, value + group * 20, value * 2, -value)
    manager.need_update.emit()

assert widget.property('curveCount') == 1
root.bindChannels()
sample_tick(1)
assert sizes() == [1, 0, 0]
widget.setCurveCount(2)
sample_tick(2)
assert sizes() == [2, 1, 0]
widget.setCurveCount(3)
sample_tick(3)
assert sizes() == [3, 2, 1]
assert widget.property('displayedCount') == 6

# Missing and invalid groups must not block other trajectories.
root.unbindAxis(1, 1)
assert sizes() == [3, 0, 1], 'rebinding cleared another trajectory'
sample_tick(4)
assert sizes() == [4, 0, 2]
root.bindCurve(1)
sample_tick(5)
before = sizes()
for group in (0, 2): root.sampleCurve(group, 200 + group, 10, 30)
root.sampleCurve(1, float('nan'), 1, 2)
manager.need_update.emit()
assert sizes() == [before[0] + 1, before[1], before[2] + 1]
root.sampleCurve(1, 99, 98, 97)
manager.need_update.emit()
assert state()[1]['last']['breakBefore'], 'invalid group did not create a break'

# Hidden groups retain their history, stop sampling, then start another segment.
before = sizes()
widget.setCurveCount(2)
sample_tick(7)
assert sizes()[2] == before[2]
assert widget.property('displayedCount') == sum(sizes()[:2])
widget.setCurveCount(3)
sample_tick(8)
assert sizes()[2] == before[2] + 1
assert state()[2]['last']['breakBefore'], 'hidden interval was bridged'

# Pause and connection changes apply to every group.
before = sizes()
widget.setProperty('paused', True)
sample_tick(9)
assert sizes() == before
widget.setProperty('paused', False)
sample_tick(10)
assert all(buffer['last']['breakBefore'] for buffer in state())
manager.connectedChanged.emit()
sample_tick(11)
assert all(buffer['last']['breakBefore'] for buffer in state())

# Capacity is per trajectory and preserves each chronological tail.
widget.clearTrail()
for value in range(550): sample_tick(value)
widget.setHistoryCapacity(500)
assert sizes() == [500, 500, 500]
assert [buffer['first']['x'] for buffer in state()] == [50, 70, 90]
widget.setHistoryCapacity(2000)
assert sizes() == [500, 500, 500], 'growing capacity erased history'
assert all(buffer['capacity'] == 2000 for buffer in state())

# Shared fit considers only enabled groups.
widget.clearTrail()
for group, x in enumerate((0, 10, 1000)): root.sampleCurve(group, x, 0, 0)
manager.need_update.emit()
widget.fitToData(True)
assert abs(widget.property('viewCenterX') - 500) < 1e-9
assert abs(widget.property('viewSpan') - 1250) < 1e-9
widget.setCurveCount(2)
widget.fitToData(True)
assert abs(widget.property('viewCenterX') - 5) < 1e-9
assert abs(widget.property('viewSpan') - 12.5) < 1e-9

# Nine bindings, count and manual view survive a fresh-instance round-trip.
widget.setCurveCount(3)
widget.setProperty('autoFit', False)
widget.setProperty('viewYaw', -33)
widget.setProperty('viewZoom', 1.75)
widget.setProperty('viewPanX', 18)
context = widget.get_widget_ctx().toVariant()
assert context['path'] == 'curve3d'
assert context['ctx']['.']['curveCount'] == 3
for group in range(3):
    for axis_index, axis in enumerate('xyz'):
        key = axis + (str(group + 1) if group else '') + '_menu'
        assert context['ctx'][key]['ctx'] == group * 3 + axis_index
root.reloadWidget()
app.processEvents()
widget = root.property('widget')
widget.set_widget_ctx(context)
assert widget.property('curveCount') == 3
assert json.loads(root.boundNames()) == ['CH' + str(i) for i in range(9)]
assert widget.property('viewYaw') == -33
assert widget.property('viewZoom') == 1.75
assert widget.property('viewPanX') == 18
# The restored objects must remain connected to live values, not static copies.
sample_tick(600)
assert [buffer['last']['x'] for buffer in state()] == [600, 620, 640]

# Explicit unbound index -1 also round-trips and leaves other bindings live.
root.unbindAxis(1, 1)
unbound_context = widget.get_widget_ctx().toVariant()
assert unbound_context['ctx']['y2_menu']['ctx'] == -1
root.reloadWidget()
app.processEvents()
widget = root.property('widget')
widget.set_widget_ctx(unbound_context)
assert json.loads(root.boundNames()) == ['CH0', 'CH1', 'CH2', 'CH3', None, 'CH5', 'CH6', 'CH7', 'CH8']

# Prior one-curve saved dashboards load with the original IDs.
legacy = copy.deepcopy(context)
legacy['ctx']['.'].pop('curveCount')
for group in (2, 3):
    for axis in 'xyz': legacy['ctx'].pop(axis + str(group) + '_menu')
root.reloadWidget()
app.processEvents()
widget = root.property('widget')
widget.set_widget_ctx(legacy)
assert widget.property('curveCount') == 1
assert json.loads(root.boundNames()) == ['CH0', 'CH1', 'CH2'] + [None] * 6

# Genuine QML screenshot: three distinct helices in one shared coordinate box.
root.bindChannels()
widget.setCurveCount(3)
widget.setProperty('autoFit', True)
widget.clearTrail()
for index in range(540):
    angle = index * math.pi / 90
    for group, radius in enumerate((50, 80, 110)):
        root.sampleCurve(group, radius * math.cos(angle), radius * math.sin(angle), angle * 9 + group * 14)
    manager.need_update.emit()
widget.resetView()
for _ in range(10):
    app.processEvents()
    time.sleep(0.02)
grab = root.grabToImage()
for _ in range(50):
    app.processEvents()
    time.sleep(0.02)
    if not grab.image().isNull(): break
image = grab.image()
assert not image.isNull()
# Check exact trajectory colors have made it into the actual raster output.
for expected in ((0x59, 0xDC, 0xE5), (0xFF, 0xB4, 0x5B), (0xF2, 0x8C, 0xDB)):
    count = 0
    for y in range(image.height()):
        for x in range(image.width()):
            pixel = image.pixelColor(x, y)
            if max(abs(pixel.red()-expected[0]), abs(pixel.green()-expected[1]), abs(pixel.blue()-expected[2])) <= 3:
                count += 1
    assert count > 100, ('trajectory color missing from render', expected, count)
path = PACKAGE_ROOT / 'preview.png'
assert image.save(str(path))
before = sizes()
root.unbindAxis(1, 1)
assert sizes() == [before[0], 0, before[2]]

view.setSource(QUrl())
view.close()
view.deleteLater()
app.sendPostedEvents(None, QEvent.DeferredDelete)
app.processEvents()
errors = [m for m in messages if any(token in m for token in (
    'ReferenceError', 'TypeError', 'SyntaxError', 'is not a type', 'Cannot assign', 'Unable to assign'))]
assert not errors, errors
print('Qt multi-curve smoke passed: 1/2/3 curves, independent sampling/breaks/history, shared fit, contexts, three-color rendering')
print(json.dumps({'qt':'5.15.2', 'host':'mock MyModules (not VOFA+ executable)',
                  'result':'passed', 'screenshot':str(path)}, ensure_ascii=True))
