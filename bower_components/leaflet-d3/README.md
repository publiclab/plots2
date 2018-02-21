# Leaflet D3 Plugin

[![Build Status][travis-image]][travis-url]

## What is it?
A collection of Leaflet plugins that enable you to leverage various d3.js visualizations directly on Leaflet maps. If you would like to use these plugins with the [Angular Leaflet Directive](https://github.com/tombatossals/angular-leaflet-directive), use the [Angular Leaflet Directive Extension ](https://github.com/Asymmetrik/angular-leaflet-directive-ext) project.

### Hexbins
Create dynamic hexbin-based heatmaps on Leaflet maps. This plugin is based on [the work of Steven Hall](http://www.delimited.io/blog/2013/12/1/hexbins-with-d3-and-leaflet-maps). The primary difference is that this plugin leverages the data-binding power of d3 to allow you to dynamically update the data and visualize the transitions.

<img src="https://cloud.githubusercontent.com/assets/480701/4594707/d995541a-5091-11e4-9955-5938b1cb977a.png" alt="map with hexbins"/>

Live Demo: [JSFiddle](http://jsfiddle.net/acjnbu8t/embedded/result/)

To use, simply declare a hexbin layer and add it to your map. You can then add data to the layer.

```js
// Options for the hexbin layer
var options = {
	radius : 10,							// Size of the hexagons/bins
	opacity: 0.5,							// Opacity of the hexagonal layer
	duration: 200,							// millisecond duration of d3 transitions (see note below)
	lng: function(d){ return d[0]; },		// longitude accessor
	lat: function(d){ return d[1]; },		// latitude accessor
	value: function(d){ return d.length; },	// value accessor - derives the bin value
	valueFloor: 0,							// override the color scale domain low value
	valueCeil: undefined,					// override the color scale domain high value
	colorRange: ['#f7fbff', '#08306b'],		// default color range for the heat map (list more than two colors to use a polylinear color scale)
	onmouseover: function(d, node, layer) {},
	onmouseout: function(d, node, layer) {},
	onclick: function(d, node, layer) {}
};

// Create the hexbin layer and add it to the map
var hexLayer = L.hexbinLayer(options).addTo(map);

// Optionally, access the d3 color scale directly
// Can also set scale via hexLayer.colorScale(d3.scale.linear()...)
hexLayer.colorScale().range(['white', 'blue']);

// Set the data (can be set multiple times)
hexLayer.data([[lng1, lat1], [lng2, lat2], ... [lngN, latN]]);

```

Special note regarding transition durations: If your data is transforming faster than the transition duration, you may encounter unexpected behavior. You should reduce the transition duration or eliminate it entirely if you are going to be using this plugin in a realtime manner.

### Pings
Create realtime animated drops/pings/blips on a map. This plugin can be used to indicate a transient event, such as a real-time occurrance of an event at a specific geographical location.

<img src="https://cloud.githubusercontent.com/assets/480701/4890582/5b6781ae-63a0-11e4-8e45-236eb7c75b85.gif" alt="map with pings"/>

Live Demo: [JSFiddle](http://jsfiddle.net/reblace/7jfhLgnq/embedded/result/)

To use, simply declare a ping layer and add it to your map. You can then add data by calling the ping() method.

```js
// Options for the ping layer
// lat & lng - custom accessor functions for accessing the latitude and longitude of the data object
// duration - how long the blip animation will last
// efficient.enabled - toggles 'efficient mode'
// efficient.fps - establishes the target framerate (rate of DOM updates for each individual object) when running in efficient mode
var options = {
	lng: function(d){ return d[0]; },
	lat: function(d){ return d[1]; },
	duration: 800,
	fps: 32
};

// Create the ping layer
var pingLayer = L.pingLayer(options).addTo(map);

// Optionally, access the radius scale and opacity scale
pingLayer.radiusScale().range([2, 18]);
pingLayer.opacityScale().range([1, 0]);

// Submit data so that it shows up as a ping with an optional per-ping css class
pingLayer.ping([longFn(), latFn()], 'myCustomCssClass');

```


## How do I include this plugin in my project?
The easiest way to include this plugin in your project, use [Bower](http://bower.io)

```bash
bower install -S leaflet-d3
```

Alternatively, you can download the source or minified javascript files yourself from the GitHub repository (they are contained in the dist directory).

Alter-alternatively, you can clone this repo and build it yourself.

Then, you can just include the src javascript file in your project.
```html
<script src="../dist/leaflet-d3.js" charset="utf-8"></script>
```

You will also need to install the dependencies, which include [d3.js](http://www.d3js.org), [d3-plugins](https://github.com/d3/d3-plugins), and [leaflet.js](http://leafletjs.com/).

```bash
bower install -S d3
bower install -S d3-plugins
bower install -S leaflet
```

## How do I build this project?
There are several tools you will need to install to build this project:
* [Node](http://nodejs.org/)
* [Gulp](http://http://gulpjs.com/)
* [Bower](http://bower.io)

If you're on Mac OS, check out [Homebrew](https://github.com/mxcl/homebrew) to get node up and running easily. It's as simple as `brew install node`

First, you will need to install the build dependencies for the project using node. If you want to use the examples, you will need to install the javascript dependencies for the project using bower. Finally, to build the project and generate the artifacts in the /dist directory, you will need to build the project using gulp. 

```bash
npm install
bower install
gulp
```

## Credits
The hexbin portion of this plugin was based on [the work of Steven Hall](http://www.delimited.io/blog/2013/12/1/hexbins-with-d3-and-leaflet-maps). Check out his other awesome work at [Delimited](http://www.delimited.io/)

d3.js was created by the legendary [Mike Bostock](https://github.com/mbostock).

[Leaflet](http://leafletjs.com/) is maintained by [lots of cool people](https://github.com/Leaflet/Leaflet/graphs/contributors).

[travis-url]: https://travis-ci.org/Asymmetrik/leaflet-d3/
[travis-image]: https://travis-ci.org/Asymmetrik/leaflet-d3.svg
