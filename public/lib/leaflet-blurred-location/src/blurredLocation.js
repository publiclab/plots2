BlurredLocation = function BlurredLocation(options) {

  var blurredLocation = this;
  var blurred = true;
  var DEFAULT_PRECISION = 6;
  require('leaflet-graticule');

  options = options || {};
  options.location = options.location || {
    lat: 1.0,
    lon: 1.0
  };

  options.zoom = options.zoom || 6;

  options.mapID = options.mapID || 'map'

  options.map = options.map || new L.Map(options.mapID,{zoomControl:false})
                                    .setView([options.location.lat, options.location.lon], options.zoom);

  options.pixels = options.pixels || 400;

  options.gridSystem = options.gridSystem || require('./core/gridSystem.js');

  options.Interface = options.Interface || require('./ui/Interface.js');

  gridSystemOptions = options.gridSystemOptions || {};
  gridSystemOptions.map = options.map;
  gridSystemOptions.gridWidthInPixels = gridWidthInPixels;
  gridSystemOptions.getMinimumGridWidth = getMinimumGridWidth;

  gridSystem = options.gridSystem(gridSystemOptions);

  InterfaceOptions = options.InterfaceOptions || {};
  InterfaceOptions.panMap = panMap;
  InterfaceOptions.getPlacenameFromCoordinates = getPlacenameFromCoordinates;
  InterfaceOptions.getLat = getLat;
  InterfaceOptions.getLon = getLon;
  InterfaceOptions.map = options.map;
  InterfaceOptions.getPrecision = getPrecision;

  Interface = options.Interface(InterfaceOptions);

  var tileLayer = L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png").addTo(options.map);

  options.map.options.scrollWheelZoom = "center";
  options.map.options.touchZoom = "center";

  // options.map.setView([options.location.lat, options.location.lon], options.zoom);

  function getLat() {
    if(isBlurred())
      return parseFloat(truncateToPrecision(options.map.getCenter().lat, getPrecision()));
    else
      return parseFloat(truncateToPrecision(options.map.getCenter().lat, DEFAULT_PRECISION));
  }

  function getLon() {
    if(isBlurred())
      return parseFloat(truncateToPrecision(options.map.getCenter().lng, getPrecision()));
    else
      return parseFloat(truncateToPrecision(options.map.getCenter().lng, DEFAULT_PRECISION));
  }
  function goTo(lat, lon, zoom) {
    options.map.setView([lat, lon], zoom);
  }

  function setZoom(zoom) {
    options.map.setZoom(zoom);
  }

  function geocodeStringAndPan(string, onComplete) {
    var url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + string.split(" ").join("+");
    var Blurred = $.ajax({
        async: false,
        url: url
    });
    onComplete = onComplete || function onComplete(geometry) {
      $("#lat").val(geometry.lat);
      $("#lng").val(geometry.lng);

      options.map.setView([geometry.lat, geometry.lng], options.zoom);
    }
    onComplete(Blurred.responseJSON.results[0].geometry.location);
  }

  function getSize() {
    return options.map.getSize();
  }

  function panMapToGeocodedLocation(selector) {
    var input = document.getElementById(selector);

    var autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.addListener('place_changed', function() {
      setTimeout(function () {
        var str = input.value;
        geocodeStringAndPan(str);
      }, 10);
    });
  };

  function panMap(lat, lng) {
    options.map.panTo(new L.LatLng(lat, lng));
  }

  function getPlacenameFromCoordinates(lat, lng, precision, onResponse) {
      $.ajax({
        url:"https://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+lng,
        success: function(result) {
          if(result.results[0]) {
            var country;
            var fullAddress = result.results[0].formatted_address.split(",");
            for (i in result.results) {
              if(result.results[i].types.indexOf("country") != -1) {
                //If the type of location is a country assign it to thr input box value
                country = result.results[i].formatted_address;
              }
            }
            if (!country) country = fullAddress[fullAddress.length - 1];

            if(precision <= 0) onResponse(country);

            else if(precision == 1) {
              if (fullAddress.length>=2) onResponse(fullAddress[fullAddress.length - 2] + ", " + country);
              else onResponse(country);
            }

            else if(precision >= 2) {
              if (fullAddress.length >= 3) onResponse(fullAddress[fullAddress.length - 3] + ", " + fullAddress[fullAddress.length - 2] + ", " + country);
              else if (fullAddress.length == 2) onResponse(fullAddress[fullAddress.length - 2] + ", " + country);
              else onResponse(country);
            }

            else onResponse(result.results[0].formatted_address);

        }
        else onResponse("Location unavailable");
      }
    });
  }

  function panMapByBrowserGeocode(checkbox) {
    var x = document.getElementById("location");
      if(checkbox.checked == true) {
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(displayPosition);
        } else {
          x.innerHTML = "Geolocation is not supported by this browser.";
        }

        function displayPosition(position) {
          panMap(parseFloat(position.coords.latitude), parseFloat(position.coords.longitude));
        }
    }
  }

  function gridWidthInPixels(degrees) {
    var p1 = L.latLng(options.map.getCenter().lat, options.map.getCenter().lng);
    var p2 = L.latLng(p1.lat+degrees, p1.lng+degrees);
    var l1 = options.map.latLngToContainerPoint(p1);
    var l2 = options.map.latLngToContainerPoint(p2);
    return {
      x: Math.abs(l2.x - l1.x),
      y: Math.abs(l2.y - l1.y),
    }
  }

  function getMinimumGridWidth(pixels) {
    var degrees = 100.0, precision = -2;
    while(gridWidthInPixels(degrees).x > pixels) {
      degrees/= 10;
      precision+= 1;
    }
    return {
      precision: precision,
      degrees: degrees,
    }
  }

  function truncateToPrecision(number, digits) {
    var multiplier = Math.pow(10, digits),
        adjustedNum = number * multiplier,
        truncatedNum = Math[adjustedNum < 0 ? 'ceil' : 'floor'](adjustedNum);

    return truncatedNum / multiplier;
  };

  function getPrecision() {
    return getMinimumGridWidth(options.pixels).precision;
  }

  function getFullLat() {
    return parseFloat(options.map.getCenter().lat);
  }

  function getFullLon() {
    return parseFloat(options.map.getCenter().lng);
  }

  function setBlurred(boolean) {
      if(boolean && !blurred) {
        gridSystem.addGrid();
        blurred = true;
      }
      else if(!boolean) {
        blurred = false;
        gridSystem.removeGrid();
      }
      updateRectangleOnPan();
  }

  function isBlurred() {
    return blurred;
  }

  var rectangle;

  function drawCenterRectangle(bounds) {
    var precision = getPrecision();
    var interval = Math.pow(0.1, precision);
    if (!bounds[1][0]) {
      if (getFullLat() < 0) { bounds[0][0] = -1*interval; bounds[1][0] = 0; }
      else { bounds[1][0] = 1*interval; }
    }
    if (!bounds[1][1]) {
      if (getFullLon() < 0) { bounds[0][1] = -1*interval; bounds[1][1] = 0; }
      else { bounds[1][1] = 1*interval; }
    }
    if (rectangle) rectangle.remove();
    rectangle = L.rectangle(bounds, {color: "#ff0000", weight: 1}).addTo(options.map);
  }

  function updateRectangleOnPan() {
    var precision = getPrecision();
    var interval = Math.pow(10,-precision);
    var bounds = [[getLat(), getLon()], [getLat() + (getLat()/Math.abs(getLat()))*interval, getLon() + (getLon()/Math.abs(getLon()))*interval]];
    if(isBlurred()) {
        drawCenterRectangle(bounds);
        disableCenterMarker();
    }
    else{
       enableCenterMarker();
       disableCenterShade();
    }
  }


  function setZoomByPrecision(precision) {
    var precisionTable = {'-2': 2, '-1': 3, '0':6, '1':10, '2':13, '3':16};
    setZoom(precisionTable[precision]);
  }

  function enableCenterShade() {
    updateRectangleOnPan();
    options.map.on('move', updateRectangleOnPan);
  }

  function disableCenterShade() {
    if(rectangle) rectangle.remove();
    options.map.off('move',updateRectangleOnPan);
  }

  var marker = L.marker([getFullLat(), getFullLon()]);

  function updateMarker() {
    if(marker) marker.remove();
    marker = L.marker([getFullLat(), getFullLon()]).addTo(options.map);
  }

  function enableCenterMarker() {
    updateMarker();
    options.map.on('move', updateMarker);
  }

  function disableCenterMarker() {
    marker.remove();
    options.map.off('move',updateMarker);
  }

  enableCenterShade();

  function geocodeWithBrowser(boolean) {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(function(position) {
      goTo(position.coords.latitude, position.coords.longitude,options.zoom);
      });
    }
  }

  function displayLocation() {
    var lat = getLat();
    var lon = getLon();
    alert("Your current location is: " + lat +  ', ' + lon);
  }

  return {
    getLat: getLat,
    getLon: getLon,
    goTo: goTo,
    getSize: getSize,
    gridSystem: gridSystem,
    panMapToGeocodedLocation: panMapToGeocodedLocation,
    getPlacenameFromCoordinates: getPlacenameFromCoordinates,
    panMap: panMap,
    panMapByBrowserGeocode: panMapByBrowserGeocode,
    getMinimumGridWidth: getMinimumGridWidth,
    gridWidthInPixels: gridWidthInPixels,
    getPrecision: getPrecision,
    setZoom: setZoom,
    Interface: Interface,
    getFullLon: getFullLon,
    getFullLat: getFullLat,
    isBlurred: isBlurred,
    setBlurred: setBlurred,
    truncateToPrecision: truncateToPrecision,
    map: options.map,
    updateRectangleOnPan: updateRectangleOnPan,
    setZoomByPrecision: setZoomByPrecision,
    disableCenterShade: disableCenterShade,
    enableCenterShade: enableCenterShade,
    geocodeStringAndPan: geocodeStringAndPan,
    geocodeWithBrowser: geocodeWithBrowser,
    displayLocation: displayLocation,
  }
}

exports.BlurredLocation = BlurredLocation;
