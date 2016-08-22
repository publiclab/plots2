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
      $('#location_map').html("");
      $('#location_map').html("<div id='map' class='col-md-6' style='height: 250px;'></div>");
      mymap = new L.map('map').setView([options.lat, options.lon], 3);

      L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png",{
        attribution: "<a href='http://openstreetmap.org'>OSM</a> tiles by <a href='http://mapbox.com'>MapBox</a>",
      }).addTo(mymap);

      var locationFilter = new L.LocationFilter().addTo(mymap);
      locationFilter.on("change", function (e) {
        bounds = locationFilter.getBounds();
        lat = bounds._northEast.lat + "," + bounds._southWest.lat;
        long = bounds._northEast.lng + "," + bounds._southWest.lng;
        console.log(lat)
        $('#latitude').val(lat);
        $('#longitude').val(long);
      });
    }
    else {
      var marker = L.marker([options.lat, options.lon], {
        draggable: true
      });
      marker.on('dragend', function(event){
        var target = event.target;
        var position = target.getLatLng();
        updateAddress(position.lat, position.lng);
      });
      marker.addTo(mymap);
    }
  }

  function updateAddress(lat, long) {
    $.getJSON("https://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+long, function(data) {
      if (data.status) {
        var address = data.results[0].formatted_address;
        $("#location-input").val(address);
      }
    });
  }
});
