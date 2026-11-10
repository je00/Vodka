/* Run with node tests/core.test.js from the package root. QML's pragma is
 * removed before loading the exact shipped implementation in a VM. */
var fs = require('fs'), vm = require('vm'), assert = require('assert');
var source = fs.readFileSync(__dirname + '/../CurveMath.js', 'utf8').replace(/^\.pragma library\s*/m, '');
var sandbox = { console: console, Number: Number, Math: Math, isFinite: isFinite };
vm.runInNewContext(source + '\nthis.api={createBuffer:createBuffer,append:append,pointAt:pointAt,markBreak:markBreak,clearBuffer:clearBuffer,setCapacity:setCapacity,bounds:bounds,boundsMany:boundsMany,project:project,renderCanvas:renderCanvas,renderManyCanvas:renderManyCanvas};', sandbox);
var a = sandbox.api;
function close(actual, expected, tolerance) {
    assert(Math.abs(actual - expected) <= (tolerance || 1e-9), actual + ' != ' + expected);
}

// Ring wrap, duplicates, invalid inputs and a pending segment break.
var b = a.createBuffer(100);
assert(a.append(b, 0, 0, 0));
assert(!a.append(b, 0, 0, 0));
assert(!a.append(b, NaN, 0, 0));
assert(!a.append(b, 1, Infinity, 0));
assert(!a.append(b, '1', 0, 0));
for (var i = 1; i <= 101; ++i) a.append(b, i, 0, 0);
assert.strictEqual(b.size, 100);
assert.strictEqual(a.pointAt(b, 0).x, 2);
assert.strictEqual(b.total, 102);
assert.strictEqual(a.pointAt(b, -1), null);
assert.strictEqual(a.pointAt(b, 100), null);
a.markBreak(b);
assert(!a.append(b, 101, 0, 0));
assert(!a.append(b, NaN, 0, 0));
a.append(b, 102, 0, 0);
assert(a.pointAt(b, b.size - 1).breakBefore);
a.append(b, 103, 0, 0);
assert(!a.pointAt(b, b.size - 1).breakBefore);

// Growing preserves the full chronological sequence; shrinking keeps the
// newest points and their break markers, without changing total accepted.
var r = a.createBuffer(200);
for (i = 0; i < 180; ++i) {
    if (i === 150) a.markBreak(r);
    a.append(r, i, i * 2, -i);
}
a.setCapacity(r, 100);
assert.strictEqual(r.size, 100);
assert.strictEqual(r.total, 180);
assert.strictEqual(a.pointAt(r, 0).x, 80);
assert(a.pointAt(r, 70).breakBefore);
a.setCapacity(r, 300);
assert.strictEqual(r.size, 100);
assert.strictEqual(a.pointAt(r, 99).x, 179);
assert(a.pointAt(r, 70).breakBefore);
a.append(r, 180, 360, -180);
assert.strictEqual(r.size, 101);
assert.strictEqual(a.pointAt(r, 100).x, 180);
a.setCapacity(r, 1); assert.strictEqual(r.capacity, 100);
a.setCapacity(r, 1e9); assert.strictEqual(r.capacity, 100000);
a.clearBuffer(r);
assert.strictEqual(r.size, 0);
assert.strictEqual(r.total, 0);
assert.strictEqual(a.bounds(r).span, 2);

// Bounds remain finite for single points and large same/opposite sign input.
var e = a.createBuffer(100);
a.append(e, 1e308, 1e308, 1e308);
assert.strictEqual(a.bounds(e).span, 2);
a.append(e, -1e308, -1e308, -1e308);
var bd = a.bounds(e);
assert(isFinite(bd.span) && bd.span > 1e308);
close(bd.cx, 0); close(bd.cy, 0); close(bd.cz, 0);
a.clearBuffer(e);
a.append(e, 1e308, 0, 0); a.append(e, 1.5e308, 0, 0);
close(a.bounds(e).span / 1e308, 0.5, 1e-14);

// Front view uses identical scale for X and Z; increasing Z moves upward.
var v = {cx:0, cy:0, cz:0, span:2, width:200, height:200, yaw:0, pitch:0, zoom:1, panX:0, panY:0};
var origin = a.project(0,0,0,v), px = a.project(1,0,0,v), pz = a.project(0,0,1,v);
close(origin.x,100); close(origin.y,100);
close(px.x-origin.x,origin.y-pz.y);
assert(pz.y < origin.y);
close(px.y,origin.y); close(pz.x,origin.x);
var giantView = {cx:0, cy:0, cz:0, span:Number.MAX_VALUE, width:900, height:600, yaw:-45, pitch:25, zoom:1, panX:0, panY:0};
var giant = a.project(1.5e308, -1.5e308, 1.5e308, giantView);
assert(isFinite(giant.x) && isFinite(giant.y) && isFinite(giant.depth));
giantView.cx = -1e308;
giant = a.project(1.5e308, 0, 0, giantView);
assert(isFinite(giant.x) && isFinite(giant.y) && isFinite(giant.depth));

// A minimal Canvas spy verifies disconnected segments and the render limit.
function canvasSpy() {
    return {
        moveCount:0, lineCount:0, labels:[], arcs:[], fillCount:0, paths:[], strokes:[], arcColors:[],
        save:function(){}, restore:function(){}, fillRect:function(){this.fillCount++;},
        beginPath:function(){this.paths.push([]);}, stroke:function(){this.strokes.push(this.strokeStyle);}, fill:function(){},
        moveTo:function(x,y){assert(isFinite(x)&&isFinite(y)); this.moveCount++; this.paths[this.paths.length-1].push(['M',x,y]);},
        lineTo:function(x,y){assert(isFinite(x)&&isFinite(y)); this.lineCount++; this.paths[this.paths.length-1].push(['L',x,y]);},
        arc:function(x,y,r){assert(isFinite(x)&&isFinite(y)); this.arcs.push([x,y,r]); this.arcColors.push(this.fillStyle);},
        fillText:function(text,x,y){assert(isFinite(x)&&isFinite(y)); this.labels.push(String(text));}
    };
}
var draw = a.createBuffer(100);
a.append(draw,0,0,0); a.append(draw,1,0,0); a.markBreak(draw); a.append(draw,2,0,0); a.append(draw,3,0,0);
var spy = canvasSpy(); a.renderCanvas(spy,draw,v,{grid:false});
assert.strictEqual(spy.moveCount,2); assert.strictEqual(spy.lineCount,2); assert.strictEqual(spy.arcs.length,1);
draw = a.createBuffer(100000);
for(i=0;i<100000;++i) {if(i===50005) a.markBreak(draw); a.append(draw,i,0,0);}
spy = canvasSpy(); a.renderCanvas(spy,draw,{cx:50000,cy:0,cz:0,span:100000,width:300,height:200},{grid:false});
assert.strictEqual(spy.moveCount+spy.lineCount,10000);
assert.strictEqual(spy.moveCount,2);
var expectedLast=a.project(99999,0,0,{cx:50000,cy:0,cz:0,span:100000,width:300,height:200});
close(spy.arcs[0][0],expectedLast.x); close(spy.arcs[0][1],expectedLast.y);
spy = canvasSpy(); a.renderCanvas(spy,e,giantView,{grid:true});
assert(spy.labels.indexOf('X')>=0 && spy.labels.indexOf('Y')>=0 && spy.labels.indexOf('Z')>=0);
assert(spy.labels.some(function(s){return /e\+/.test(s);}));

// Union bounds ignore empty/unbound curves and use the extrema of every
// enabled trajectory. Adding an empty curve must not move a remote curve.
var remote=a.createBuffer(100), remote2=a.createBuffer(100), empty=a.createBuffer(100);
a.append(remote,100,200,300); a.append(remote,110,220,330);
var union=a.boundsMany([null,empty,remote]);
assert.strictEqual(union.minX,100); assert.strictEqual(union.maxX,110);
assert.strictEqual(union.minY,200); assert.strictEqual(union.maxY,220);
assert.strictEqual(union.minZ,300); assert.strictEqual(union.maxZ,330);
close(union.cx,105); close(union.cy,210); close(union.cz,315); close(union.span,30);
a.append(remote2,90,210,340); a.append(remote2,120,215,350);
union=a.boundsMany([remote,remote2,empty]);
assert.strictEqual(union.minX,90); assert.strictEqual(union.maxX,120);
assert.strictEqual(union.minY,200); assert.strictEqual(union.maxY,220);
assert.strictEqual(union.minZ,300); assert.strictEqual(union.maxZ,350);
close(union.cx,105); close(union.cy,210); close(union.cz,325); close(union.span,50);
assert.strictEqual(a.boundsMany([]).span,2);
assert.strictEqual(a.boundsMany([empty,null]).cx,0);
var extreme1=a.createBuffer(100), extreme2=a.createBuffer(100);
a.append(extreme1,-1e308,0,0); a.append(extreme2,1e308,0,0);
assert(isFinite(a.boundsMany([extreme1,extreme2]).span));

// Three entries use three colours but only one background and one grid. Each
// trail starts its own path, so no segment can join different trajectories.
var first=a.createBuffer(100), second=a.createBuffer(100), third=a.createBuffer(100);
a.append(first,0,0,0); a.append(first,1,0,0);
a.append(second,0,0,0); a.append(second,0,0,1);
a.append(third,0,0,0); a.append(third,-1,0,0);
var entries=[{buffer:first,color:'#59dce5'},{buffer:second,color:'#ffb45b'},{buffer:third,color:'#f28cdb'}];
spy=canvasSpy(); a.renderManyCanvas(spy,entries,v,{grid:false});
assert.strictEqual(spy.fillCount,1);
assert.strictEqual(spy.moveCount,3); assert.strictEqual(spy.lineCount,3);
assert.deepStrictEqual(spy.strokes,['#59dce5','#ffb45b','#f28cdb']);
assert.deepStrictEqual(spy.arcColors,['#59dce5','#ffb45b','#f28cdb']);
var trailPaths=spy.paths.filter(function(path){return path.length>0;});
assert.strictEqual(trailPaths.length,3);
for(i=0;i<trailPaths.length;++i) {
    assert.strictEqual(trailPaths[i][0][0],'M');
    assert.strictEqual(trailPaths[i][1][0],'L');
    // The common starting coordinate shares the same projection in all paths.
    close(trailPaths[i][0][1],origin.x); close(trailPaths[i][0][2],origin.y);
}
spy=canvasSpy(); a.renderManyCanvas(spy,entries,v,{grid:true});
assert.strictEqual(spy.fillCount,1);
assert.strictEqual(spy.labels.filter(function(s){return s==='X';}).length,1);
assert.strictEqual(spy.labels.filter(function(s){return s==='Y';}).length,1);
assert.strictEqual(spy.labels.filter(function(s){return s==='Z';}).length,1);
// Without a supplied centre/span, the same shared union bounds are used for
// every entry rather than independently fitting each curve.
spy=canvasSpy(); a.renderManyCanvas(spy,[{buffer:remote},{buffer:remote2}],{width:400,height:300},{grid:false});
var unionView={cx:union.cx,cy:union.cy,cz:union.cz,span:union.span,width:400,height:300};
var last=a.pointAt(remote,remote.size-1), unionProjected=a.project(last.x,last.y,last.z,unionView);
close(spy.arcs[0][0],unionProjected.x); close(spy.arcs[0][1],unionProjected.y);
spy=canvasSpy(); a.renderManyCanvas(spy,[],{width:400,height:300},{grid:true});
assert.strictEqual(spy.fillCount,1); assert.strictEqual(spy.arcs.length,0);
console.log('CurveMath: ring, resize, validation, breaks, bounds, equal-scale projection, shared multi-curve bounds and rendering tests passed');
