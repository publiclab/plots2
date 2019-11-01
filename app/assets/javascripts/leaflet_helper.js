  function setupLeafletMap() {
    //Bounding map.  
    var bounds = new L.LatLngBounds(new L.LatLng(84.67351257 , -172.96875) , new L.LatLng(-54.36775852 , 178.59375)) ;
    var map = L.map('map_leaflet' , {
      maxBounds: bounds , 
      maxBoundsViscosity: 0.75
    }) ;
    return map ;
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


  function PLmarker_default(){
     L.Icon.PLmarker = L.Icon.extend({
      options: {
        iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-black.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41]
      }
   });
    return new L.Icon.PLmarker();
  }

   function peopleLayerParser(map, markers_hash) {
       var NWlat = map.getBounds().getNorthWest().lat ;
       var NWlng = map.getBounds().getNorthWest().lng ;
       var SElat = map.getBounds().getSouthEast().lat ;
       var SElng = map.getBounds().getSouthEast().lng ;
       map.spin(true) ;
       let people_url = "/api/srch/nearbyPeople?nwlat=" + NWlat + "&selat=" + SElat + "&nwlng=" + NWlng + "&selng=" + SElng;
       $.getJSON(people_url , function (data) {
           if (!!data.items) {
               for (i = 0; i < data.items.length; i++) {
                   var default_markers = PLmarker_default();
                   var mid = data.items[i].doc_id ;
                   var url = data.items[i].doc_url;
                   var title = data.items[i].doc_title;
                   var m = L.marker([data.items[i].latitude, data.items[i].longitude], {
                       title: title,
                       icon: default_markers
                   }) ;
                   if(markers_hash.has(mid) === false){
                       m.addTo(map).bindPopup("<a href=" + url + ">" + title + "</a>") ;
                       markers_hash.set(mid , m) ;
                   }
               }
           }
           map.spin(false) ;
       });
   }

   function contentLayerParser(map,markers_hash, map_tagname) {
       var NWlat = map.getBounds().getNorthWest().lat ;
       var NWlng = map.getBounds().getNorthWest().lng ;
       var SElat = map.getBounds().getSouthEast().lat ;
       var SElng = map.getBounds().getSouthEast().lng ;
       map.spin(true) ;
       if(map_tagname === null || (typeof map_tagname === "undefined")) {
           taglocation_url = "/api/srch/taglocations?nwlat=" + NWlat + "&selat=" + SElat + "&nwlng=" + NWlng + "&selng=" + SElng ;

       } else {
           taglocation_url = "/api/srch/taglocations?nwlat=" + NWlat + "&selat=" + SElat + "&nwlng=" + NWlng + "&selng=" + SElng + "&tag=" + map_tagname ;
       }
       $.getJSON(taglocation_url , function (data) {
           if (!!data.items) {
               for (i = 0; i < data.items.length; i++) {
                   var url = data.items[i].doc_url;
                   var title = data.items[i].doc_title;
                   var default_url = PLmarker_default();
                   var mid = data.items[i].doc_id ;
                   var m = L.marker([data.items[i].latitude, data.items[i].longitude], {icon: default_url}).bindPopup("<a href=" + url + ">" + title + "</a>") ;
                   
                   if(markers_hash.has(mid) === false){

                       m.addTo(map).bindPopup("<a href=" + url + ">" + title + "</a>") ;
                       markers_hash.set(mid , m) ;
                   }
               }
           }
           map.spin(false) ;
       });
   }

   

   function setupInlineLEL(map , layers, mainLayer, markers_hash) {

       layers = layers.split(',');

       L.tileLayer('https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png').addTo(map) ;

       L.LayerGroup.EnvironmentalLayers({
           include: layers,
       }).addTo(map);

       if(typeof mainLayer !== "undefined" && mainLayer !== ""){
           if(mainLayer === "people"){
               
               map.on('zoomend' , function () {
                  peopleLayerParser(map, markers_hash);
               }) ;

               map.on('moveend' , function () {
                   peopleLayerParser(map, markers_hash);
               }) ;
           }
           else if(mainLayer === "content"){
               
               map.on('zoomend' , function () {
                   contentLayerParser(map, markers_hash);
               }) ;

               map.on('moveend' , function () {
                   contentLayerParser(map, markers_hash);
               }) ;
           }
           else { // it is a tagname

               map.on('zoomend' , function () {
                   contentLayerParser(map, markers_hash, mainLayer);
               }) ;

               map.on('moveend' , function () {
                   contentLayerParser(map, markers_hash, mainLayer);
               }) ;
           }
       }
   }

   function setupLEL(map , sethash){
      L.tileLayer('https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      }).addTo(map) ;

      L.LayerGroup.EnvironmentalLayers({
          hash: !!sethash,
      }).addTo(map);
   }