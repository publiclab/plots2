$(document).ready(function() {

  if (window.hasOwnProperty('google')) {

    var geo_location = document.getElementById('geo_location');
    var autocomplete = new google.maps.places.Autocomplete(geo_location);

    autocomplete.addListener('place_changed', function() {
      var place = autocomplete.getPlace();

      var user = $('#infoform').data('user');
      $.ajax({
        url: "/profile/location/create/" + user,
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
            var mymap = new L.map('map').setView([response.location.lat, response.location.lon], 15);
            if (response.location_privacy) {
              var lat = response.location.lat;
              var long = response.location.lon;

              L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png",{
                attribution: "<a href='http://openstreetmap.org'>OSM</a> tiles by <a href='http://mapbox.com'>MapBox</a>",
              }).addTo(mymap);

              var marker = L.marker([lat, long]).addTo(mymap);
              marker.bindPopup("<b>" + response.name + "</b>").openPopup();

            } else {
              var lat  = parseFloat(response.location.lat).toFixed(4);
              var long = parseFloat(response.location.lon).toFixed(4);

              var options = {
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

              L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png",{
                attribution: "<a href='http://openstreetmap.org'>OSM</a> tiles by <a href='http://mapbox.com'>MapBox</a>",
              }).addTo(mymap);

              var hexlayer = L.hexbinLayer(options).addTo(mymap);
              hexlayer.colorScale().range(["white", "grey"]);

              hexlayer.data([[lat, long]]);
            }
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
        url: '/profile/user/privacy',
        type: 'POST',
        data: {
          location_privacy: status,
          id: $('#infoform').data('user')
        },
        success: function(data) {

          if (data.status) {
            $(that).prop('checked', data.model.location_privacy);
            if (data.model.location_privacy) {
              if (data.lat && data.long) {
                $("#location_map").html("<div class='col-md-8' id='map' style='height: 300px;'></div>");
                var mymap = new L.map('map').setView([data.lat, data.long], 15);

                L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png",{
                  attribution: "<a href='http://openstreetmap.org'>OSM</a> tiles by <a href='http://mapbox.com'>MapBox</a>",
                }).addTo(mymap);

                var marker = L.marker([data.lat, data.long]).addTo(mymap);
                marker.bindPopup("<b>" + data.model.username + "</b>").openPopup();
              }

            }
            else {
              if (data.lat && data.long) {
                $("#location_map").html("<div class='col-md-8' id='map' style='height: 300px;'></div>");
                var lat = parseFloat(data.lat).toFixed(4);
                var long = parseFloat(data.long).toFixed(4);
                var mymap = new L.map('map').setView([lat, long], 15);

                var options = {
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

                L.tileLayer("https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png",{
                  attribution: "<a href='http://openstreetmap.org'>OSM</a> tiles by <a href='http://mapbox.com'>MapBox</a>",
                }).addTo(mymap);


                var hexlayer = L.hexbinLayer(options).addTo(mymap);
                hexlayer.colorScale().range(["white", "grey"]);

                hexlayer.data([[lat, long]]);
              }

            }
          }

        }

      })

    });

  }

});
