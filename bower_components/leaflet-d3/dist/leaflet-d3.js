/*! leaflet-d3.js Version: 0.3.8 */
(function(){
	"use strict";

	// L is defined by the Leaflet library, see git://github.com/Leaflet/Leaflet.git for documentation
	L.HexbinLayer = L.Class.extend({
		includes: [L.Mixin.Events],

		options : {
			radius : 10,
			opacity: 0.5,
			duration: 200,
			lng: function(d){
				return d[0];
			},
			lat: function(d){
				return d[1];
			},
			value: function(d){
				return d.length;
			},
			valueFloor: undefined,
			valueCeil: undefined,
			colorRange: ['#f7fbff', '#08306b'],

			onmouseover: undefined,
			onmouseout: undefined,
			click: undefined
		},

		initialize : function(options) {
			L.setOptions(this, options);

			this._hexLayout = d3.hexbin()
				.radius(this.options.radius)
				.x(function(d){ return d.point[0]; })
				.y(function(d){ return d.point[1]; });

			this._data = [];
			this._colorScale = d3.scale.linear()
				.range(this.options.colorRange)
				.clamp(true);

		},

		onAdd : function(map) {
			this._map = map;

			// Create a container for svg.
			this._container = this._initContainer();

			// Set up events
			map.on({'moveend': this._redraw}, this);

			// Initial draw
			this._redraw();
		},

		onRemove : function(map) {
			this._destroyContainer();

			// Remove events
			map.off({'moveend': this._redraw}, this);

			this._container = null;
			this._map = null;

			// Explicitly will leave the data array alone in case the layer will be shown again
			//this._data = [];
		},

		addTo : function(map) {
			map.addLayer(this);
			return this;
		},

		_initContainer : function() {
			var container = null;

			// If the container is null or the overlay pane is empty, create the svg element for drawing
			if (null == this._container) {
				var overlayPane = this._map.getPanes().overlayPane;
				container = d3.select(overlayPane).append('svg')
					.attr('class', 'leaflet-layer leaflet-zoom-hide');
			}

			return container;
		},

		_destroyContainer: function(){
			// Remove the svg element
			if(null != this._container){
				this._container.remove();
			}
		},

		// (Re)draws the hexbin group
		_redraw : function(){
			var that = this;

			if (!that._map) {
				return;
			}

			// Generate the mapped version of the data
			var data = that._data.map(function(d) {
				var lng = that.options.lng(d);
				var lat = that.options.lat(d);

				var point = that._project([lng, lat]);
				return { o: d, point: point };
			});

			var zoom = this._map.getZoom();

			// Determine the bounds from the data and scale the overlay
			var padding = this.options.radius * 2;
			var bounds = this._getBounds(data);
			var width = (bounds.max[0] - bounds.min[0]) + (2 * padding),
				height = (bounds.max[1] - bounds.min[1]) + (2 * padding),
				marginTop = bounds.min[1] - padding,
				marginLeft = bounds.min[0] - padding;

			this._hexLayout.size([ width, height ]);
			this._container
				.attr('width', width).attr('height', height)
				.style('margin-left', marginLeft + 'px')
				.style('margin-top', marginTop + 'px');

			// Select the hex group for the current zoom level. This has 
			// the effect of recreating the group if the zoom level has changed
			var join = this._container.selectAll('g.hexbin')
				.data([zoom], function(d){ return d; });

			// enter
			join.enter().append('g')
				.attr('class', function(d) { return 'hexbin zoom-' + d; });

			// enter + update
			join.attr('transform', 'translate(' + -marginLeft + ',' + -marginTop + ')');

			// exit
			join.exit().remove();

			// add the hexagons to the select
			this._createHexagons(join, data);

		},

		_createHexagons : function(g, data) {
			var that = this;

			// Create the bins using the hexbin layout
			var bins = that._hexLayout(data);

			// Determine the extent of the values
			var extent = d3.extent(bins, function(d){
				return that.options.value(d);
			});
			if(null == extent[0]) extent[0] = 0;
			if(null == extent[1]) extent[1] = 0;
			if(null != that.options.valueFloor) extent[0] = that.options.valueFloor;
			if(null != that.options.valueCeil) extent[1] = that.options.valueCeil;

			// Match the domain cardinality to that of the color range, to allow for a polylinear scale
			var domain = that._linearlySpace(extent[0], extent[1], that._colorScale.range().length);

			// Set the colorscale domain
			that._colorScale.domain(domain);

			// Join - Join the Hexagons to the data
			var join = g.selectAll('path.hexbin-hexagon')
				.data(bins, function(d){ return d.i + ':' + d.j; });

			// Update - set the fill and opacity on a transition (opacity is re-applied in case the enter transition was cancelled)
			join.transition().duration(that.options.duration)
				.attr('fill', function(d){ return that._colorScale(that.options.value(d)); })
				.attr('fill-opacity', that.options.opacity)
				.attr('stroke-opacity', that.options.opacity);
	
			// Enter - establish the path, the fill, and the initial opacity
			join.enter().append('path').attr('class', 'hexbin-hexagon')
				.attr('d', function(d){ return 'M' + d.x + ',' + d.y + that._hexLayout.hexagon(); })
				.attr('fill', function(d){ return that._colorScale(that.options.value(d)); })
				.attr('fill-opacity', 0.01)
				.attr('stroke-opacity', 0.01)
				.on('mouseover', function(d, i) {
					if(null != that.options.onmouseover) {
						that.options.onmouseover(d, this, that);
					}
				})
				.on('mouseout', function(d, i) {
					if(null != that.options.onmouseout) {
						that.options.onmouseout(d, this, that);
					}
				})
				.on('click', function(d, i) {
					if(null != that.options.onclick) {
						that.options.onclick(d, this, that);
					}
				})
				.transition().duration(that.options.duration)
					.attr('fill-opacity', that.options.opacity)
					.attr('stroke-opacity', that.options.opacity);

			// Exit
			join.exit().transition().duration(that.options.duration)
				.attr('fill-opacity', 0.01)
				.attr('stroke-opacity', 0.01)
				.remove();

		},

		_project : function(coord) {
			var point = this._map.latLngToLayerPoint([ coord[1], coord[0] ]);
			return [ point.x, point.y ];
		},

		_getBounds: function(data){
			var that = this;

			if(null == data || data.length < 1){
				return { min: [0,0], max: [0,0]};
			}

			// bounds is [[min long, min lat], [max long, max lat]]
			var bounds = [[999, 999], [-999, -999]];

			data.forEach(function(element){
				var x = element.point[0];
				var y = element.point[1];

				bounds[0][0] = Math.min(bounds[0][0], x);
				bounds[0][1] = Math.min(bounds[0][1], y);
				bounds[1][0] = Math.max(bounds[1][0], x);
				bounds[1][1] = Math.max(bounds[1][1], y);
			});

			return { min: bounds[0], max: bounds[1] };
		},

		_linearlySpace: function(from, to, length){
			var arr = new Array(length);
			var step = (to - from) / Math.max(length - 1, 1);

			for (var i = 0; i < length; ++i) {
				arr[i] = from + (i * step);
			}

			return arr;
		},

		/* 
		 * Setter for the data
		 */
		data : function(data) {
			this._data = (null != data)? data : [];
			this._redraw();
			return this;
		},

		/*
		 * Getter/setter for the colorScale
		 */
		colorScale: function(colorScale) {
			if(undefined === colorScale){
				return this._colorScale;
			}

			this._colorScale = colorScale;
			this._redraw();
			return this;
		},

		/*
		 * Getter/Setter for the value function
		 */
		value: function(valueFn) {
			if(undefined === valueFn){
				return this.options.value;
			}

			this.options.value = valueFn;
			this._redraw();
			return this;
		},

		/*
		 * Getter/setter for the mouseover function
		 */
		onmouseover: function(mouseoverFn) {
			this.options.onmouseover = mouseoverFn;
			this._redraw();
			return this;
		},

		/*
		 * Getter/setter for the mouseout function
		 */
		onmouseout: function(mouseoutFn) {
			this.options.onmouseout = mouseoutFn;
			this._redraw();
			return this;
		},

		/*
		 * Getter/setter for the click function
		 */
		onclick: function(clickFn) {
			this.options.onclick = clickFn;
			this._redraw();
			return this;
		}

	});

	L.hexbinLayer = function(options) {
		return new L.HexbinLayer(options);
	};

})();

(function(){
	"use strict";

	// L is defined by the Leaflet library, see git://github.com/Leaflet/Leaflet.git for documentation
	L.PingLayer = L.Class.extend({
		includes: [L.Mixin.Events],

		/*
		 * Configuration
		 */
		options : {
			lng: function(d){
				return d[0];
			},
			lat: function(d){
				return d[1];
			},
			fps: 32,
			duration: 800
		},

		_lastUpdate: Date.now(),
		_fps: 0,

		_mapBounds: undefined,

		/*
		 * Public Methods
		 */

		/*
		 * Getter/setter for the radius
		 */
		radiusScale: function(radiusScale) {
			if(undefined === radiusScale){
				return this._radiusScale;
			}

			this._radiusScale = radiusScale;
			return this;
		},

		/*
		 * Getter/setter for the opacity
		 */
		opacityScale: function(opacityScale) {
			if(undefined === opacityScale){
				return this._opacityScale;
			}

			this._opacityScale = opacityScale;
			return this;
		},

		// Initialization of the plugin
		initialize : function(options) {
			L.setOptions(this, options);

			this._radiusScale = d3.scale.pow().exponent(0.35)
				.domain([0, this.options.duration])
				.range([3, 15])
				.clamp(true);
			this._opacityScale = d3.scale.linear()
				.domain([0, this.options.duration])
				.range([1, 0])
				.clamp(true);
		},

		// Called when the plugin layer is added to the map
		onAdd : function(map) {
			this._map = map;

			// Init the state of the simulation
			this._running = false;

			// Create a container for svg.
			this._container = this._initContainer();
			this._updateContainer();

			// Set up events
			map.on({'move': this._move}, this);
		},

		// Called when the plugin layer is removed from the map
		onRemove : function(map) {
			this._destroyContainer();

			// Remove events
			map.off({'move': this._move}, this);

			this._container = null;
			this._map = null;
			this._data = null;
		},

		// Add the layer to the map
		addTo : function(map) {
			map.addLayer(this);
			return this;
		},

		/*
		 * Method by which to "add" pings
		 */
		ping : function(data, cssClass) {
			this._add(data, cssClass);
			this._expire();

			// Start timer if not active
			if(!this._running && this._data.length > 0) {
				this._running = true;
				this._lastUpdate = Date.now();

				var that = this;
				d3.timer(function() { return that._update.apply(that); });
			}

			return this;
		},

		getFps : function() {
			return this._fps;
		},

		getCount : function() {
			return this._data.length;
		},

		/*
		 * Private Methods
		 */

		// Initialize the Container - creates the svg pane
		_initContainer : function() {
			var container = null;

			// If the container is null or the overlay pane is empty, create the svg element for drawing
			if (null == this._container) {
				var overlayPane = this._map.getPanes().overlayPane;
				container = d3.select(overlayPane).append('svg')
					.attr('class', 'leaflet-layer leaflet-zoom-hide');
			}

			return container;
		},

		// Update the container - Updates the dimensions of the svg pane
		_updateContainer : function() {
			var bounds = this._getMapBounds();
			this._mapBounds = bounds;

			this._container
				.attr('width', bounds.width).attr('height', bounds.height)
				.style('margin-left', bounds.left + 'px')
				.style('margin-top', bounds.top + 'px');
		},

		// Cleanup the svg pane
		_destroyContainer: function() {
			// Remove the svg element
			if(null != this._container){
				this._container.remove();
			}
		},

		// Calculate the current map bounds
		_getMapBounds: function(){
			var latLongBounds = this._map.getBounds();
			var ne = this._map.latLngToLayerPoint(latLongBounds.getNorthEast());
			var sw = this._map.latLngToLayerPoint(latLongBounds.getSouthWest());

			var bounds = {
				width: ne.x - sw.x,
				height: sw.y - ne.y,
				left: sw.x,
				top: ne.y
			};

			return bounds;
		},

		// Update the map based on zoom/pan/move
		_move: function() {
			this._updateContainer();
		},

		// Add a ping to the map
		_add : function(data, cssClass) {
			// Lazy init the data array
			if(null == this._data) this._data = [];

			// Derive the spatial data
			var geo = [this.options.lat(data), this.options.lng(data)];
			var point = this._map.latLngToLayerPoint(geo);
			var mapBounds = this._mapBounds;

			// Add the data to the list of pings
			var circle = {
				geo: geo,
				x: point.x - mapBounds.left, y: point.y - mapBounds.top,
				ts: Date.now(),
				nts: 0
			};
			circle.c = this._container.append('circle')
				.attr('class', (null != cssClass)? 'ping ' + cssClass : 'ping')
				.attr('cx', circle.x)
				.attr('cy', circle.y)
				.attr('r', this.radiusScale().range()[0]);

			// Push new circles
			this._data.push(circle);
		},

		// Main update loop
		_update : function() {
			var nowTs = Date.now();
			if(null == this._data) this._data = [];

			var maxIndex = -1;

			// Update everything
			for(var i=0; i < this._data.length; i++) {
				var d = this._data[i];
				var age = nowTs - d.ts;

				if(this.options.duration < age){
					// If the blip is beyond it's life, remove it from the dom and track the lowest index to remove
					d.c.remove();
					maxIndex = i;
				} else {

					// If the blip is still alive, process it
					if(d.nts < nowTs) {
						d.c.attr('r', this.radiusScale()(age))
						   .attr('fill-opacity', this.opacityScale()(age))
						   .attr('stroke-opacity', this.opacityScale()(age));
						d.nts = Math.round(nowTs + 1000/this.options.fps);
					}
				}
			}

			// Delete all the aged off data at once
			if(maxIndex > -1) {
				this._data.splice(0, maxIndex + 1);
			}

			// The return function dictates whether the timer loop will continue
			this._running = (this._data.length > 0);

			if(this._running) {
				this._fps = 1000/(nowTs - this._lastUpdate);
				this._lastUpdate = nowTs;
			}

			return !this._running;
		},

		// Expire old pings
		_expire : function() {
			var maxIndex = -1;
			var nowTs = Date.now();

			// Search from the front of the array
			for(var i=0; i < this._data.length; i++) {
				var d = this._data[i];
				var age = nowTs - d.ts;

				if(this.options.duration < age) {
					// If the blip is beyond it's life, remove it from the dom and track the lowest index to remove
					d.c.remove();
					maxIndex = i;
				} else {
					break;
				}
			}

			// Delete all the aged off data at once
			if(maxIndex > -1) {
				this._data.splice(0, maxIndex + 1);
			}
		}

	});

	L.pingLayer = function(options) {
		return new L.PingLayer(options);
	};

})();
