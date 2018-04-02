  function setupLeafletMap() {
    //Bounding map.  
    var bounds = new L.LatLngBounds(new L.LatLng(84.67351257 , -172.96875) , new L.LatLng(-54.36775852 , 178.59375)) ;
    var map = L.map('map_leaflet' , {
      maxBounds: bounds , 
      maxBoundsViscosity: 0.75
    }) ;
    return map ;
  }

  function setupLayers(map) {
    var mapboxUrl = "//a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png" ;
    var normal_layer = L.tileLayer(mapboxUrl, {id: 'map'}) ; 
    normal_layer.addTo(map) ; 
    map.options.minZoom = 1 ;
    var baseMaps = {
      "Default": normal_layer,
    };
    var overlayMaps = {
      "Skynet": layerGroup    // we can add more layers here !
    }; 
    L.control.layers(baseMaps , overlayMaps).addTo(map);
  }

  function setupFullScreen(map , lat , lon) {
    map.addControl(new L.Control.Fullscreen()); // to go full-screen
    map.on('fullscreenchange', function () {
      if (map.isFullscreen()) {
        map.options.minZoom = 3 ;
       } 
      else {
        map.options.minZoom = 1 ;
        map.panTo(new L.LatLng(lat,lon));
      }
    });
  }

  function onMapLoad(e){
	// ADD MORE AJAX CALLS INSIDE THIS FUNCTION !
      $.getJSON(skynet_url , function(data){
       if (!!data.feed){
        for (i = 0 ; i < data.feed.length ; i++) { 
          var lat = data.feed[i].lat ;
          var lng = data.feed[i].lng;
          var title = data.feed[i].title ;
          var url = data.feed[i].link ;
          var skymarker ; 
          if (!isNaN(parseInt(lat)) && !isNaN(parseInt(lng)) ){
          skymarker = L.marker([parseInt(lat) , parseInt(lng)] , {icon: redDotIcon}).bindPopup(title + "<br><a>" + url +"</a>" + "<br><strong> lat: " + lat + "</strong><br><strong> lon: " + lng + "</strong>") ;
          layerGroup.addLayer(skymarker);
          }
        }
       }  
     });
   }
