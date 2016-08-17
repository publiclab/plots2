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

      var circle = L.circle([lat, long], 150, {
        color: 'red'
      }).addTo(mymap);

      circle.addTo(mymap);

      circle.on('mousedown', function (event) {
        mymap.dragging.disable();
        let {lat: circleStartingLat, lng: circleStartingLng} = circle._latlng;
        let {lat: mouseStartingLat, lng: mouseStartingLng} = event.latlng;


        mymap.on('mousemove', event => {
          let {lat: mouseNewLat, lng: mouseNewLng} = event.latlng;
          let latDifference = mouseStartingLat - mouseNewLat;
          let lngDifference = mouseStartingLng - mouseNewLng;

          let center = [circleStartingLat-latDifference, circleStartingLng-lngDifference];
          circle.setLatLng(center);
        });
      });

      mymap.on('mouseup', () => { 
        mymap.dragging.enable();
        mymap.removeEventListener('mousemove');
        var lat = parseFloat(circle.getLatLng().lat).toFixed(5);
        var lng = parseFloat(circle.getLatLng().lng).toFixed(5);
        updateAddress(lat, lng);
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
