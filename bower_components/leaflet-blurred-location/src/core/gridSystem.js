module.exports = function gridSystem(options) {

  var map = options.map || document.getElementById("map") || L.map('map');
  options.cellSize = options.cellSize || { rows:100, cols:100 };

  require('leaflet-graticule');
  // require('../Leaflet.Graticule.js');

  options.graticuleOptions = options.graticuleOptions || {
                 showLabel: true,
                 zoomInterval: [
                   {start: 2, end: 2, interval: 100},
                   {start: 2, end: 5, interval: 10},
                   {start: 5, end: 9, interval: 1},
                   {start: 9, end: 12, interval: 0.1},
                   {start: 12, end: 15, interval: 0.01},
                   {start: 15, end: 20, interval: 0.001},
                 ],
                 opacity: 1,
                 color: '#ff0000',
                 latFormatTickLabel: function(lat) {
                            var decimalPlacesAfterZero = 0;
                            lat = lat.toString();
                            for(i in this.zoomInterval) {
                              if(map.getZoom() >= this.zoomInterval[i].start && map.getZoom() <= this.zoomInterval[i].end && this.zoomInterval[i].interval < 1)
                                decimalPlacesAfterZero = (this.zoomInterval[i].interval + '').split('.')[1].length;
                            }
                            if (lat < 0) {
                                lat = lat * -1;
                                lat = lat.toString();
                                if(lat.indexOf(".") != -1) lat = lat.split('.')[0] + '.' + lat.split('.')[1].slice(0,decimalPlacesAfterZero);
                                return '' + lat + 'S';
                            }
                            else if (lat > 0) {
                                if(lat.indexOf(".") != -1) lat = lat.split('.')[0] + '.' + lat.split('.')[1].slice(0,decimalPlacesAfterZero)
                                return '' + lat + 'N';
                            }
                            return '' + lat;
                          },

                lngFormatTickLabel: function(lng) {
                           var decimalPlacesAfterZero = 0;
                           lng = lng.toString();
                           for(i in this.zoomInterval) {
                             if(map.getZoom() >= this.zoomInterval[i].start && map.getZoom() <= this.zoomInterval[i].end && this.zoomInterval[i].interval < 1)
                               decimalPlacesAfterZero = (this.zoomInterval[i].interval + '').split('.')[1].length;
                           }
                           if (lng > 180) {
                               lng = 360 - lng;
                               lng = lng.toString();
                               if(lng.indexOf(".") != -1) lng = lng.split('.')[0] + '.' + lng.split('.')[1].slice(0,decimalPlacesAfterZero)
                               return '' + lng + 'W';
                           }
                           else if (lng > 0 && lng < 180) {
                             if(lng.indexOf(".") != -1) lng = lng.split('.')[0] + '.' + lng.split('.')[1].slice(0,decimalPlacesAfterZero)
                             return '' + lng + 'E';
                           }
                           else if (lng < 0 && lng > -180) {
                               lng = lng * -1;
                               lng = lng.toString();
                               if(lng.indexOf(".") != -1) lng = lng.split('.')[0] + '.' + lng.split('.')[1].slice(0,decimalPlacesAfterZero)
                               return '' + lng + 'W';
                           }
                           else if (lng == -180) {
                               lng = lng*-1;
                               if(lng.indexOf(".") != -1) lng = lng.split('.')[0] + '.' + lng.split('.')[1].slice(0,decimalPlacesAfterZero)
                               return '' + lng;
                           }
                           else if (lng < -180) {
                               lng  = 360 + lng;
                               if(lng.indexOf(".") != -1) lng = lng.split('.')[0] + '.' + lng.split('.')[1].slice(0,decimalPlacesAfterZero)
                               return '' + lng + 'W';
                           }
                           else if(lng == 0) {
                             return '' + lng;
                           }
                         },
             }


  var layer = L.latlngGraticule(options.graticuleOptions).addTo(map);

  function addGrid() {
     layer = L.latlngGraticule(options.graticuleOptions).addTo(map);
  }

  function removeGrid() {
  layer.remove();
  }

  return {
    removeGrid: removeGrid,
    addGrid: addGrid,
  }
}
