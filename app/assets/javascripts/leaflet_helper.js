  function setupLeafletMap() {
    //Bounding map.  
    var bounds = new L.LatLngBounds(new L.LatLng(84.67351257 , -172.96875) , new L.LatLng(-54.36775852 , 178.59375)) ;
    var map = L.map('map_leaflet' , {
      maxBounds: bounds , 
      maxBoundsViscosity: 0.75
    }) ;
    return map ;
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

   function contentLayerParser(map, markers_hash, map_tagname) {
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
                   var author = data.items[i].doc_author;
                   var image_url = data.items[i].doc_image_url;
                   var default_url = PLmarker_default();
                   var mid = data.items[i].doc_id ;
                   var m = L.marker([data.items[i].latitude, data.items[i].longitude], {icon: default_url}).bindPopup("<a href=" + url + ">" + title + "</a>") ;
                   
                   if(markers_hash.has(mid) === false){

                       if(image_url) {
                           m.addTo(map).bindPopup("<div><img src=" + image_url+ " height='140px' /><br>" + "<b>Title:</b> " + title  + "<br><b>Author:</b>   <a href=" + 'https://publiclab.org/profile/' + author + ">" + author + "</a><br>" + "<a href=" + url + ">" + "Read more..." + "</a></div>" ) ;
                       } else {
                           m.addTo(map).bindPopup("<span><b>Title:</b>     " + title  + "</span><br><span><b>Author:</b>    <a href=" + 'https://publiclab.org/profile/' + author + ">" + author + "</a></span><br>" + "<a href=" + url + ">" + "<br>Read more..." + "</a>" ) ;
                       }
                       markers_hash.set(mid , m) ;
                   }
               }
           }
           map.spin(false) ;
       });
   }

   function setupLEL(map, markers_hash = null, params = {}) {
      var options = {};
      options.layers = params.layers || [];                 // display these layers on the map
      options.limitMenuTo = params.limitMenuTo || [];       // limit available layers in menu to only those listed, default all layers in menu
      options.setHash = params.setHash || false;
      options.mainContent = params.mainContent || "";       // "content" to show site content, default "" shows no site content
      options.displayAllLayers = params.displayAllLayers || false;  // turn on display for all maps available in menu

      if (typeof options.layers === "string") {
        options.layers = options.layers.split(',');
      }

      var oms = omsUtil(map, {
         keepSpiderfied: true,
         circleSpiralSwitchover: 0
      });

      var optionsLEL = { };
      if (options.layers.length > 0) {
         optionsLEL.addLayersToMap = options.displayAllLayers;
         optionsLEL.display = options.layers;
         optionsLEL.include = options.limitMenuTo;
         optionsLEL.hash = options.setHash;
      }
      L.LayerGroup.EnvironmentalLayers(optionsLEL).addTo(map);

      displayMapContent(map, markers_hash, options.mainContent);
   }

   function displayMapContent(map, markers_hash, mainContent) {
      if(typeof mainContent !== "undefined" && mainContent !== ""){
         if(mainContent === "people"){
            peopleMap();
            map.on('zoomend', peopleMap);
            map.on('moveend', peopleMap);
         }
         else {
            mainContent = (mainContent === "content") ? null : mainContent;
            contentMap();
            map.on('zoomend', contentMap);
            map.on('moveend', contentMap);
         }
      }

      function contentMap() {
         contentLayerParser(map, markers_hash, mainContent);
      }
      function peopleMap() {
         peopleLayerParser(map, markers_hash);
      }
   }