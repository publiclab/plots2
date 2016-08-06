$(document).ready(function() {

  if (window.hasOwnProperty('google')) {
    var location = document.getElementById('location-input');
    var autocomplete = new google.maps.places.Autocomplete(location);

    autocomplete.addListener('place_changed', function() {
      var place = autocomplete.getPlace();

      $('#location-input').attr('value', place.formatted_address);
      initMap();
    });
  }


  function initMap() {
    $('#location_map').html("<div id='map' class='col-md-6' style='height: 250px;'></div>");
    mymap = new L.map('map').setView([123, 34], 15);

    L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png",{
      attribution: "<a href='http://openstreetmap.org'>OSM</a> tiles by <a href='http://mapbox.com'>MapBox</a>",
    }).addTo(mymap);

    var location_privacy = $('#location-privacy').is(':checked');

    if (location_privacy) {
      var marker = L.marker([123, 34]).addTo(mymap);
    }
    else {
      
    }
  }
});
