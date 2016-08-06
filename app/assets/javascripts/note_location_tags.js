$(document).ready(function() {

  if (window.hasOwnProperty('google')) {
    var location = document.getElementById('location-input');
    var autocomplete = new google.maps.places.Autocomplete(location);

    autocomplete.addListener('place_changed', function() {
      var place = autocomplete.getPlace();
      $('#location-input').attr('value', place.formatted_address);

      var geocoder = new google.maps.Geocoder();
      geocoder.geocode( { 'address': place.formatted_address}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK)
        {
          options = {
            lat: results[0].geometry.location.lat(),
            lon: results[0].geometry.location.lng()
          }

          window.initiateMap(options);
        }
      });
    });
  }

  $('#display-location').click(function() {
    location_display = $('#display-location').is(":checked");
    if(location_display) {
      $('#location-info').show();
    }
    else {
      $('#location-info').hide();
    }
  });


  window.initiateMap = function(options = {}) {
    $('#location_map').html("<div id='map' class='col-md-6' style='height: 250px;'></div>");
    mymap = new L.map('map').setView([options.lat, options.lon], 15);

    L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png",{
      attribution: "<a href='http://openstreetmap.org'>OSM</a> tiles by <a href='http://mapbox.com'>MapBox</a>",
    }).addTo(mymap);

    var location_privacy = $('#location-privacy').is(':checked');

    if (location_privacy) {
      lat = options.lat;
      long = options.lon;

      var hexbin = {
        radius : 20,                            // Size of the hexagons/bins
        opacity: 0.5,                           // Opacity of the hexagonal layer
        duration: 200,                          // millisecond duration of d3 transitions (see note below)
        lng: function(d){ return d[1]; },       // longitude accessor
        lat: function(d){ return d[0]; },       // latitude accessor
        value: function(d){ return d.length; }, // value accessor - derives the bin value
        valueFloor: 0,                          // override the color scale domain low value
        valueCeil: undefined,                   // override the color scale domain high value
        colorRange: ['#f7fbff', '#08306b'],     // default color range for the heat map (see note below)
        onmouseover: function(d, node, layer) {},
        onmouseout: function(d, node, layer) {},
        onclick: function(d, node, layer) {}
      }

      var hexlayer = L.hexbinLayer(hexbin).addTo(mymap);
      hexlayer.colorScale().range(["white", "grey"]);

      hexlayer.data([[lat, long]]);
    }
    else {
      var marker = L.marker([options.lat, options.lon]).addTo(mymap);
    }
  }
});
