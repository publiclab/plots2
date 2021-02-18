  function setupLeafletMap() {
    //Bounding map.  
    var bounds = new L.LatLngBounds(new L.LatLng(84.67351257 , -172.96875) , new L.LatLng(-54.36775852 , 178.59375)) ;
    var map = L.map('map_leaflet' , {
      maxBounds: bounds , 
      maxBoundsViscosity: 0.75
    }) ;
    return map ;
  }

  function PLmarker_default(color = 'black'){
     // valid colors: blue, gold, green, orange, yellow, violet, grey, black
     L.Icon.PLmarker = L.Icon.extend({
      options: {
        iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-'+color+'.png',
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
               var nodetype = data.items[i].doc_type;
               nodetype = nodetype.charAt(0).toUpperCase() + nodetype.slice(1).toLowerCase();

               var place_name = data.items[i].place_name;
               var url = data.items[i].doc_url;
               var title = data.items[i].doc_title;
               var author = data.items[i].doc_author;
               var image_url = data.items[i].doc_image_url;
               var map_marker = PLmarker_default('blue');
               var mid = data.items[i].doc_id;
               var created_at = data.items[i].created_at;
               var time_since = TimeAgo().inWords(new Date(data.items[i].created_at));
               // var comment_count = data.items[i].comment_count;

               var m = L.marker([data.items[i].latitude, data.items[i].longitude], {icon: map_marker});

               if(markers_hash.has(mid) === false){
                  var popup_content = "";
                  if (image_url) popup_content += "<img src='" + image_url + "' class='popup-thumb' />";
                  popup_content += "<h5><a href='" + url + "'>" + limit_words(title, 10)  + "</a></h5>";
                  popup_content += "<div class='popup-two-column'>";
                     popup_content += "<div class='popup-stretch-column'>" + nodetype + " by <a href='https://publiclab.org/profile/" + author + "'>@" + author + "</a> " + time_since + "</div><br>";
                     if (nodetype.toLowerCase() === "wiki") popup_content += "<div class='map-slug popup-shrink-column'><a href='/map/" + url.split('/').pop() + "'>#</a></div>";
                  popup_content += "</div>";
                  // if (place_name) popup_content += "<span><b>Place: </b>" + place_name + "</span><br>";

                  var popup = L.popup({
                     maxWidth: 300,
                     autoPan: false,
                     className: 'map-popup'
                  }).setContent(popup_content);
                  m.addTo(map).bindPopup(popup_content);
         
                  markers_hash.set(mid , m) ;
               }
            }
         }
         map.spin(false) ;
      });

      function limit_words(str, num_words) {
         return str.split(" ").splice(0, num_words).join(" ");
      }
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
         optionsLEL.imageLoadingUrl = "/lib/leaflet-environmental-layers/example/images/owmloading.gif";
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
