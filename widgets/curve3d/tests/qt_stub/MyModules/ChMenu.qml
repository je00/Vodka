import QtQuick 2.12
Item {
 property string title: ''
 property color color: 'white'
 property bool checked: false
 property var bind_obj: null
 property var ctx
 // VOFA+ 1.3.10 persists the channel index, including 0, or -1 when unbound.
 // Look up the real test channel object so restored bindings stay live.
 onCtxChanged: {
  if (typeof ctx === "number")
   bind_obj = testChannelRegistry.channel(ctx);
 }
 function get_ctx() {
  return bind_obj ? testChannelRegistry.indexOfChannel(bind_obj) : -1;
 }
}
