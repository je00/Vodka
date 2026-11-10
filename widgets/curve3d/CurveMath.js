.pragma library

// Small, dependency-free geometry helper used by the Curve3D QML widget.
// The file deliberately uses ES5 syntax: VOFA+ releases target Qt 5.14.

var MIN_CAPACITY = 100;
var MAX_CAPACITY = 100000;
var MAX_RENDER_POINTS = 10000;
var MAX_VALUE = Number.MAX_VALUE || 1.7976931348623157e308;

function finite(v) {
    return typeof v === "number" && isFinite(v);
}

function clampCapacity(v) {
    v = Math.floor(Number(v));
    if (!finite(v)) v = 2000;
    if (v < MIN_CAPACITY) v = MIN_CAPACITY;
    if (v > MAX_CAPACITY) v = MAX_CAPACITY;
    return v;
}

function createBuffer(capacity) {
    capacity = clampCapacity(capacity);
    return {
        capacity: capacity,
        size: 0,
        // total is the number of accepted (non-duplicate) samples, including
        // samples that have since fallen out of the ring.
        total: 0,
        start: 0,
        pendingBreak: false,
        xs: [], ys: [], zs: [], breaks: []
    };
}

function physicalIndex(buffer, logicalIndex) {
    return (buffer.start + logicalIndex) % buffer.capacity;
}

function pointAt(buffer, index) {
    if (!buffer || index < 0 || index >= buffer.size) return null;
    var p = physicalIndex(buffer, index);
    return {
        x: buffer.xs[p],
        y: buffer.ys[p],
        z: buffer.zs[p],
        breakBefore: !!buffer.breaks[p]
    };
}

function append(buffer, x, y, z) {
    if (!buffer || !finite(x) || !finite(y) || !finite(z)) return false;
    if (buffer.size > 0) {
        var last = pointAt(buffer, buffer.size - 1);
        if (last && last.x === x && last.y === y && last.z === z) {
            // Keep a pending break until a different point arrives. This is
            // useful when a source is restarted while its first sample is
            // equal to the previous source's last sample.
            return false;
        }
    }

    var p = physicalIndex(buffer, buffer.size < buffer.capacity ? buffer.size : 0);
    if (buffer.size >= buffer.capacity) {
        p = buffer.start;
        buffer.start = (buffer.start + 1) % buffer.capacity;
    } else {
        buffer.size++;
    }
    buffer.xs[p] = x;
    buffer.ys[p] = y;
    buffer.zs[p] = z;
    buffer.breaks[p] = !!buffer.pendingBreak;
    buffer.pendingBreak = false;
    buffer.total++;
    return true;
}

function markBreak(buffer) {
    if (buffer) buffer.pendingBreak = true;
}

function clearBuffer(buffer) {
    if (!buffer) return;
    buffer.size = 0;
    buffer.total = 0;
    buffer.start = 0;
    buffer.pendingBreak = false;
}

function setCapacity(buffer, capacity) {
    if (!buffer) return null;
    capacity = clampCapacity(capacity);
    if (capacity === buffer.capacity) return buffer;
    var old = [];
    var i;
    for (i = 0; i < buffer.size; ++i) old.push(pointAt(buffer, i));
    var keep = Math.min(old.length, capacity);
    var first = old.length - keep;
    buffer.capacity = capacity;
    buffer.start = 0;
    buffer.size = 0;
    buffer.xs = [];
    buffer.ys = [];
    buffer.zs = [];
    buffer.breaks = [];
    for (i = first; i < old.length; ++i) {
        var q = old[i];
        var p = buffer.size++;
        buffer.xs[p] = q.x;
        buffer.ys[p] = q.y;
        buffer.zs[p] = q.z;
        buffer.breaks[p] = q.breakBefore;
    }
    return buffer;
}

function stableRange(a, b) {
    if (a === b) return 0;
    var aa = Math.abs(a), bb = Math.abs(b), large = Math.max(aa, bb), small = Math.min(aa, bb);
    var r;
    // Same-sign values use subtraction. It remains safe even when both
    // values are close to Number.MAX_VALUE (large-small <= large). For
    // opposite signs the range is a sum and may genuinely exceed the
    // representable range, in which case saturating is the only useful
    // finite answer.
    if ((a < 0) === (b < 0)) {
        r = large - small;
    } else if (large <= MAX_VALUE / 2) {
        r = Math.abs(b - a);
    } else {
        // Avoid overflow in b-a for opposite signed values.
        r = large * (1 + small / large);
    }
    return finite(r) ? r : MAX_VALUE;
}

function midpoint(a, b) {
    // Halving before adding avoids overflowing for two large values of the
    // same sign; unlike (a+b)/2 this remains finite for all finite inputs.
    return a / 2 + b / 2;
}

function bounds(buffer) {
    var out = {cx: 0, cy: 0, cz: 0, span: 2,
               minX: 0, maxX: 0, minY: 0, maxY: 0, minZ: 0, maxZ: 0};
    if (!buffer || buffer.size === 0) return out;
    var p = pointAt(buffer, 0), minX = p.x, maxX = p.x;
    var minY = p.y, maxY = p.y, minZ = p.z, maxZ = p.z;
    var i, q;
    for (i = 1; i < buffer.size; ++i) {
        q = pointAt(buffer, i);
        if (q.x < minX) minX = q.x; if (q.x > maxX) maxX = q.x;
        if (q.y < minY) minY = q.y; if (q.y > maxY) maxY = q.y;
        if (q.z < minZ) minZ = q.z; if (q.z > maxZ) maxZ = q.z;
    }
    var rx = stableRange(minX, maxX), ry = stableRange(minY, maxY), rz = stableRange(minZ, maxZ);
    var span = Math.max(rx, ry, rz);
    if (!finite(span) || span <= 0) span = 2;
    out.minX = minX; out.maxX = maxX; out.minY = minY; out.maxY = maxY; out.minZ = minZ; out.maxZ = maxZ;
    out.cx = midpoint(minX, maxX); out.cy = midpoint(minY, maxY); out.cz = midpoint(minZ, maxZ);
    out.span = span;
    return out;
}

// Only the caller's enabled buffers participate in the shared world bounds.
// Empty buffers must not contribute their default origin or span: otherwise
// an unbound curve would change the scale of an already populated curve.
function boundsMany(buffers) {
    var combined = null;
    buffers = buffers || [];
    for (var i = 0; i < buffers.length; ++i) {
        var buffer = buffers[i];
        if (!buffer || buffer.size === 0) continue;
        var b = bounds(buffer);
        if (!combined) {
            combined = b;
        } else {
            combined.minX = Math.min(combined.minX, b.minX);
            combined.maxX = Math.max(combined.maxX, b.maxX);
            combined.minY = Math.min(combined.minY, b.minY);
            combined.maxY = Math.max(combined.maxY, b.maxY);
            combined.minZ = Math.min(combined.minZ, b.minZ);
            combined.maxZ = Math.max(combined.maxZ, b.maxZ);
        }
    }
    if (!combined) return bounds(null);
    combined.cx = midpoint(combined.minX, combined.maxX);
    combined.cy = midpoint(combined.minY, combined.maxY);
    combined.cz = midpoint(combined.minZ, combined.maxZ);
    combined.span = Math.max(stableRange(combined.minX, combined.maxX),
                             stableRange(combined.minY, combined.maxY),
                             stableRange(combined.minZ, combined.maxZ));
    if (!finite(combined.span) || combined.span <= 0) combined.span = 2;
    return combined;
}

function finiteOr(v, fallback) { return finite(v) ? v : fallback; }

function project(x, y, z, view) {
    view = view || {};
    var cx = finiteOr(view.cx, 0), cy = finiteOr(view.cy, 0), cz = finiteOr(view.cz, 0);
    var span = finiteOr(view.span, 2); if (span <= 0) span = 2;
    var width = finiteOr(view.width, 1), height = finiteOr(view.height, 1);
    var dx = x - cx, dy = y - cy, dz = z - cz;
    // Normalize before rotation: two individually finite rotation terms
    // could otherwise sum to Infinity near Number.MAX_VALUE.
    dx = finite(dx) ? dx / span : x / span - cx / span;
    dy = finite(dy) ? dy / span : y / span - cy / span;
    dz = finite(dz) ? dz / span : z / span - cz / span;
    return projectNormalized(dx, dy, dz, view);
}

function projectNormalized(dx, dy, dz, view) {
    var width = finiteOr(view.width, 1), height = finiteOr(view.height, 1);
    var yaw = finiteOr(view.yaw, -45) * Math.PI / 180;
    var pitch = finiteOr(view.pitch, 25) * Math.PI / 180;
    var zoom = finiteOr(view.zoom, 1); if (zoom <= 0) zoom = 1;
    var panX = finiteOr(view.panX, 0), panY = finiteOr(view.panY, 0);
    var cYaw = Math.cos(yaw), sYaw = Math.sin(yaw);
    var cPitch = Math.cos(pitch), sPitch = Math.sin(pitch);
    var rx = dx * cYaw - dy * sYaw;
    var ry = dx * sYaw + dy * cYaw;
    var vertical = dz * cPitch - ry * sPitch;
    var depth = ry * cPitch + dz * sPitch;
    // The projected cube can be taller than one world span after rotation.
    // Keep the complete box and its tick labels inside the initial viewport.
    var scale = Math.min(Math.max(width, 1), Math.max(height, 1)) * 0.52 * zoom;
    if (!finite(scale)) scale = 0;
    var sx = width / 2 + panX + rx * scale;
    var sy = height / 2 + panY - vertical * scale;
    if (!finite(sx)) sx = sx < 0 ? -MAX_VALUE : MAX_VALUE;
    if (!finite(sy)) sy = sy < 0 ? -MAX_VALUE : MAX_VALUE;
    return {x: sx, y: sy, depth: finite(depth) ? depth : 0};
}

function drawLine(ctx, a, b) {
    ctx.moveTo(a.x, a.y); ctx.lineTo(b.x, b.y);
}

function renderCanvas(ctx, buffer, view, options) {
    options = options || {};
    renderManyCanvas(ctx, [{buffer: buffer, color: options.color || "#59dce5"}], view, options);
}

// Draw a single coordinate system followed by independent, coloured trails.
// All entries share v, so equal world coordinates always project to the same
// position regardless of the individual trajectory's size and location.
function renderManyCanvas(ctx, entries, view, options) {
    if (!ctx) return;
    options = options || {};
    entries = entries || [];
    view = view || {};
    var width = finiteOr(view.width, ctx.canvas ? ctx.canvas.width : 300);
    var height = finiteOr(view.height, ctx.canvas ? ctx.canvas.height : 200);
    var buffers = [];
    var i;
    for (i = 0; i < entries.length; ++i) {
        if (entries[i]) buffers.push(entries[i].buffer);
    }
    var b = boundsMany(buffers);
    var v = {cx: finiteOr(view.cx, b.cx), cy: finiteOr(view.cy, b.cy), cz: finiteOr(view.cz, b.cz),
             span: finiteOr(view.span, b.span), width: width, height: height,
             yaw: finiteOr(view.yaw, -45), pitch: finiteOr(view.pitch, 25), zoom: finiteOr(view.zoom, 1),
             panX: finiteOr(view.panX, 0), panY: finiteOr(view.panY, 0)};
    if (v.span <= 0) v.span = 2;
    ctx.save();
    ctx.fillStyle = options.background || "#101b2b";
    ctx.fillRect(0, 0, width, height);
    if (options.grid !== false) drawGrid(ctx, v);
    for (i = 0; i < entries.length; ++i) {
        var entry = entries[i];
        if (entry) drawTrajectory(ctx, entry.buffer, v, entry.color || "#59dce5");
    }
    ctx.restore();
}

function drawGrid(ctx, view) {
    // Coordinates below are already normalized relative to the view centre.
    // This permits a finite grid even at enormous world-space offsets.
    var half = 0.5, cx = 0, cy = 0, cz = 0;
    var corners = [
        [cx-half, cy-half, cz-half], [cx+half, cy-half, cz-half],
        [cx+half, cy+half, cz-half], [cx-half, cy+half, cz-half],
        [cx-half, cy-half, cz+half], [cx+half, cy-half, cz+half],
        [cx+half, cy+half, cz+half], [cx-half, cy+half, cz+half]
    ];
    var edges = [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]];
    ctx.strokeStyle = "#31506a"; ctx.lineWidth = 1; ctx.beginPath();
    var i, a, z;
    for (i=0;i<edges.length;++i) { a=projectNormalized(corners[edges[i][0]][0],corners[edges[i][0]][1],corners[edges[i][0]][2],view); z=projectNormalized(corners[edges[i][1]][0],corners[edges[i][1]][1],corners[edges[i][1]][2],view); drawLine(ctx,a,z); }
    ctx.stroke();
    ctx.strokeStyle = "#20394e";
    var j, k, t, p1, p2, n=4;
    for (j=0;j<=n;++j) { t=j/n; ctx.beginPath();
        p1=projectNormalized(cx-half+t,cy-half,cz-half,view); p2=projectNormalized(cx-half+t,cy+half,cz-half,view); drawLine(ctx,p1,p2);
        p1=projectNormalized(cx-half,cy-half+t,cz-half,view); p2=projectNormalized(cx+half,cy-half+t,cz-half,view); drawLine(ctx,p1,p2); ctx.stroke(); }
    ctx.fillStyle="#a9c2d6"; ctx.font="10px sans-serif";
    var labels=[["X",cx+half,cy-half,cz-half,"#ff8b92"],["Y",cx-half,cy+half,cz-half,"#83db91"],["Z",cx-half,cy-half,cz+half,"#8caeff"]];
    for(k=0;k<labels.length;++k){var lp=projectNormalized(labels[k][1],labels[k][2],labels[k][3],view); ctx.fillStyle=labels[k][4]; ctx.fillText(labels[k][0],lp.x+6,lp.y-8);}
    ctx.fillStyle = "#6e8ba2";
    for(j=0;j<=n;++j){
        t=j/n-0.5;
        p1=projectNormalized(t,-0.5,-0.5,view);
        ctx.fillText(tickText(view.cx+t*view.span),p1.x-6,p1.y+14);
        p1=projectNormalized(-0.5,t,-0.5,view);
        ctx.fillText(tickText(view.cy+t*view.span),p1.x+5,p1.y+10);
        p1=projectNormalized(-0.5,-0.5,t,view);
        ctx.fillText(tickText(view.cz+t*view.span),p1.x-38,p1.y+3);
    }
}

function tickText(value) {
    if (!finite(value)) return value < 0 ? "-overflow" : "overflow";
    if (Math.abs(value) < 1e-12) return "0";
    if (Math.abs(value) >= 10000 || Math.abs(value) < 0.01) return value.toExponential(1);
    return Number(value.toPrecision(3)).toString();
}

function drawTrajectory(ctx, buffer, view, color) {
    if (!buffer || buffer.size === 0) return;
    var total=buffer.size, count=Math.min(total,MAX_RENDER_POINTS), step=count>1?(total-1)/(count-1):1;
    ctx.strokeStyle=color; ctx.lineWidth=2; ctx.lineJoin="round"; ctx.lineCap="round";
    var i, q, p, previous=null, sample=0, next=0;
    ctx.beginPath();
    for(i=0;i<total;++i){
        q=pointAt(buffer,i);
        if(i!==0 && q.breakBefore) previous=null;
        if(i!==next) continue;
        p=project(q.x,q.y,q.z,view);
        if(!previous){ctx.moveTo(p.x,p.y);} else {ctx.lineTo(p.x,p.y);} previous=p;
        sample++; next=Math.round(sample*step);
    }
    ctx.stroke();
    q=pointAt(buffer,total-1); p=project(q.x,q.y,q.z,view);
    ctx.fillStyle=color; ctx.beginPath(); ctx.arc(p.x,p.y,3,0,Math.PI*2); ctx.fill();
}

