$(document).ready(function() {
  var geo_location = document.getElementById('geo_location');
  var autocomplete = new google.maps.places.Autocomplete(geo_location);

  autocomplete.addListener('place_changed', function() {
    var place = autocomplete.getPlace();

    var user = $('#infoform').data('user');
    $.ajax({
      url: "/info/location/create/" + user,
      type: "POST",
      data: {
        type: 'location',
        value: {
          address: place.formatted_address
        }
      },
      success: function(data) {
        response = data;
        if (response.status) {
          $("#location_map").html("<div class='col-md-8' id='map' style='height: 300px;'></div>");
          var mymap = new L.map('map').setView([response.location.lat, response.location.long], 15);

          L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png",{
            attribution: "<a href='http://openstreetmap.org'>OSM</a> tiles by <a href='http://mapbox.com'>MapBox</a>",
          }).addTo(mymap);

          var circle = L.circle([response.location.lat, response.location.long], 300, {
            color: 'blue',
            fillColor: '#87CEFA',
            fillOpacity: 0.5
          }).addTo(mymap);

        }
        else {
          $("#geo_location").append('<span class="help-block">'+response['errors']+'</span>');
        }
      }
    })
  })

  $('#location_privacy').click(function(e) {
    e.preventDefault();
    that = this
    var status = $(this).is(':checked')

    $.ajax({
      url: '/info/privacy',
      type: 'POST',
      data: {
        location_privacy: status
      },
      success: function(data) {

        if (data.status) {
          $(that).prop('checked', data.model.location_privacy)

        }

      }
    })

  });

});
