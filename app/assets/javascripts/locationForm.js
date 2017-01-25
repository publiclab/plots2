function addGrid(map)
 {function create_cell_style(fill) {
   return {
       stroke: true,
       color: '#3ac1f0',
       dashArray: null,
       lineCap: null,
       lineJoin: null,
       weight: 2,
       opacity: 1,

       fill: fill,
       fillColor: null, //same as color by default
       fillOpacity: 0.5,

       clickable: true
     }
 }
 L.VirtualGrid = L.FeatureGroup.extend({
   include: L.Mixin.Events,
   options: {
     cellSize: 64,
     delayFactor: 2.5,
   },
   initialize: function(options){
     L.Util.setOptions(this, options);
     L.FeatureGroup.prototype.initialize.call(this, [], options);
   },
   onAdd: function(map){
     L.FeatureGroup.prototype.onAdd.call(this, map);
     this._map = map;
     this._cells = [];
     this._setupGrid(map.getBounds());

     map.on("move", this._moveHandler, this);
     map.on("zoomend", this._zoomHandler, this);
     map.on("resize", this._resizeHandler, this);
   },
   onRemove: function(map){
     L.FeatureGroup.prototype.onRemove.call(this, map);
     map.off("move", this._moveHandler, this);
     map.off("zoomend", this._zoomHandler, this);
     map.off("resize", this._resizeHandler, this);
   },
   _clearLayer: function(e) {
     this._cells = [];
   },
   _moveHandler: function(e){
     this._renderCells(e.target.getBounds());
   },
   _zoomHandler: function(e){
     this.clearLayers();
     this._renderCells(e.target.getBounds());
   },
   _renderCells: function(bounds) {
     var cells = this._cellsInBounds(bounds);
     this.focused_cell_id = cells.length == 0 ? null : cells[0].id;
     this.fire("newcells", cells);
     for (var i = cells.length - 1; i >= 0; i--) {
       var cell = cells[i];

       if(this._loadedCells.indexOf(cell.id) === -1){
         var should_fill_cell = cell.id == this.focused_cell_id;
         (function(cell, i){
           var cur_style = create_cell_style(should_fill_cell);
           setTimeout(this.addLayer.bind(this, L.rectangle(cell.bounds, cur_style)), this.options.delayFactor*i);
         }.bind(this))(cell, i);
         this._loadedCells.push(cell.id);
       }
     }
   },
   _resizeHandler: function(e) {
     this._setupSize();
   },
   _setupSize: function(){
     this._rows = Math.ceil(this._map.getSize().x / this._cellSize);
     this._cols = Math.ceil(this._map.getSize().y / this._cellSize);
   },
   _setupGrid: function(bounds){
     this._origin = this._map.project(bounds.getNorthWest());
     this._cellSize = this.options.cellSize;
     this._setupSize();
     this._loadedCells = [];
     this.clearLayers();
     this._renderCells(bounds);
   },
   _cellPoint:function(row, col){
     var x = this._origin.x + (row*this._cellSize);
     var y = this._origin.y + (col*this._cellSize);
     return new L.Point(x, y);
   },
   _cellExtent: function(row, col){
     var swPoint = this._cellPoint(row, col);
     var nePoint = this._cellPoint(row-1, col-1);
     var sw = this._map.unproject(swPoint);
     var ne = this._map.unproject(nePoint);
     return new L.LatLngBounds(ne, sw);
   },
   _cellsInBounds: function(bounds){
     var offset = this._map.project(bounds.getNorthWest());
     var center = bounds.getCenter();
     var offsetX = this._origin.x - offset.x;
     var offsetY = this._origin.y - offset.y;
     var offsetRows = Math.round(offsetX / this._cellSize);
     var offsetCols = Math.round(offsetY / this._cellSize);
     var cells = [];
     for (var i = 0; i <= this._rows; i++) {
       for (var j = 0; j <= this._cols; j++) {
         var row = i-offsetRows;
         var col = j-offsetCols;
         var cellBounds = this._cellExtent(row, col);
         var cellId = row+":"+col;
         cells.push({
           id: cellId,
           bounds: cellBounds,
           distance:cellBounds.getCenter().distanceTo(center),
         });
       }
     }
     cells.sort(function (a, b) {
       return a.distance - b.distance;
     });
     return cells;
   }
 });

 L.virtualGrid = function(url, options){
   return new L.VirtualGrid(options);
 };

 L.virtualGrid({
   cellSize: 64
 }).addTo(map);
 }
