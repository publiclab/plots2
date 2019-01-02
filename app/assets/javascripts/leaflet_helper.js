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
          if (!isNaN((lat)) && !isNaN((lng)) ){
          skymarker = L.marker([(lat) , (lng)] , {icon: redDotIcon}).bindPopup(title + "<br><a>" + url +"</a>" + "<br><strong> lat: " + lat + "</strong><br><strong> lon: " + lng + "</strong>") ;
          layerGroup.addLayer(skymarker);
          }
        }
       }  
     });
   }

   function setupLEL(map , sethash){ 

    var baselayer = L.tileLayer('https://a.tiles.mapbox.com/v3/jywarren.map-lmrwb2em/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map) ; 
   // var PurpleLayer = L.layerGroup.purpleLayer() ;
    var PurpleAirMarkerLayer = L.layerGroup.purpleAirMarkerLayer() ;
    var SkyTruth = L.layerGroup.skyTruthLayer() ;
    var Fractracker = L.layerGroup.fracTrackerLayer() ;
    var OdorReport = L.layerGroup.odorReportLayer() ;
    var MapKnitter = L.layerGroup.mapKnitterLayer() ;
    var ToxicRelease = L.layerGroup.toxicReleaseLayer() ;

    var OpenInfraMap_Power = L.tileLayer('https://tiles-{s}.openinframap.org/power/{z}/{x}/{y}.png',{
        maxZoom: 18,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://www.openinframap.org/about.html">About OpenInfraMap</a>'
    });
    var OpenInfraMap_Petroleum = L.tileLayer('https://tiles-{s}.openinframap.org/petroleum/{z}/{x}/{y}.png', {
      maxZoom: 18,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://www.openinframap.org/about.html">About OpenInfraMap</a>'
    });
    var OpenInfraMap_Telecom = L.tileLayer('https://tiles-{s}.openinframap.org/telecoms/{z}/{x}/{y}.png', {
      maxZoom: 18,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://www.openinframap.org/about.html">About OpenInfraMap</a>'
    });
    var OpenInfraMap_Water = L.tileLayer('https://tiles-{s}.openinframap.org/water/{z}/{x}/{y}.png',{
      maxZoom: 18,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://www.openinframap.org/about.html">About OpenInfraMap</a>'
    });

    var Justicemap_income = L.tileLayer.provider('JusticeMap.income') ;
    var JusticeMap_americanIndian = L.tileLayer.provider('JusticeMap.americanIndian') ;
    var JusticeMap_asian = L.tileLayer.provider('JusticeMap.asian') ;
    var JusticeMap_black = L.tileLayer.provider('JusticeMap.black') ;
    var JusticeMap_multi = L.tileLayer.provider('JusticeMap.multi') ;
    var JusticeMap_hispanic = L.tileLayer.provider('JusticeMap.hispanic') ;
    var JusticeMap_nonWhite = L.tileLayer.provider('JusticeMap.nonWhite') ;
    var JusticeMap_white = L.tileLayer.provider('JusticeMap.white') ;
    var JusticeMap_plurality = L.tileLayer.provider('JusticeMap.plurality') ;
    
    var clouds = L.OWM.clouds({showLegend: true, opacity: 0.5});
    var cloudscls = L.OWM.cloudsClassic({});
    var precipitation = L.OWM.precipitation({});
    var precipitationcls = L.OWM.precipitationClassic({});
    var rain = L.OWM.rain({});
    var raincls = L.OWM.rainClassic({});
    var snow = L.OWM.snow({});
    var pressure = L.OWM.pressure({});
    var pressurecntr = L.OWM.pressureContour({});
    var temp = L.OWM.temperature({});
    var wind = L.OWM.wind({});

    var city = L.OWM.current({intervall: 15, minZoom: 3});
    var windrose = L.OWM.current({intervall: 15, minZoom: 3, markerFunction: myWindroseMarker, popup: false, clusterSize: 50,imageLoadingBgUrl: 'https://openweathermap.org/img/w0/iwind.png' });
    windrose.on('owmlayeradd', windroseAdded, windrose); 

    var baseMaps = {
      "Baselayer1": baselayer
    };
    var overlayMaps = {
     // "PurpleAirLayer-HeatMap": PurpleLayer ,
      "PurpleAirLayer-Markers": PurpleAirMarkerLayer ,
      "SkyTruth": SkyTruth , 
      "Fractracker" : Fractracker ,
      "ToxicRelease": ToxicRelease ,
      "OdorReport": OdorReport ,
      "MapKnitter": MapKnitter ,
      "OpenInfraMap_Power": OpenInfraMap_Power ,
      "OpenInfraMap_Telecom": OpenInfraMap_Telecom ,
      "OpenInfraMap_Petroleum": OpenInfraMap_Petroleum ,
      "OpenInfraMap_Water": OpenInfraMap_Water ,
      "Justicemap_income": Justicemap_income,
      "JusticeMap_americanIndian": JusticeMap_americanIndian ,
      "JusticeMap_asian": JusticeMap_asian ,
      "JusticeMap_black": JusticeMap_black,
      "JusticeMap_multi": JusticeMap_multi ,
      "JusticeMap_hispanic": JusticeMap_hispanic ,
      "JusticeMap_nonWhite": JusticeMap_nonWhite,
      "JusticeMap_white": JusticeMap_white ,
      "JusticeMap_plurality": JusticeMap_plurality ,
         "Clouds": clouds ,
         "clouds (classic)": cloudscls ,
         "precipitation": precipitation ,
         "precipitation (classic)": precipitationcls , 
         "rain": rain , 
         "rain (classic)": raincls ,
         "snow": snow , 
         "pressure": pressure ,
         "pressure contour (zoom in)": pressurecntr , 
         "temp": temp , 
         "wind": wind , 
         "Cities (zoom in)": city  , 
         "windrose (zoom in)": windrose
    };
    
    if(sethash == 1) {
      var allMapLayers = {
        "BL1": baselayer,

        "Wisconsin_NM": Wisconsin_NM,
        "FT_mobile": FracTracker_mobile,
        "Purple": PurpleAirMarkerLayer,
        "STruth": SkyTruth,
        "FracTL": Fractracker,
        "ToxicR": ToxicRelease,
        "OdorR": OdorReport,
        "MapK": MapKnitter,
        "OIMPower": OpenInfraMap_Power,
        "OIMapTelecom": OpenInfraMap_Telecom,
        "OIMPetroleum": OpenInfraMap_Petroleum,
        "OIMWater": OpenInfraMap_Water,
        "JMincome": Justicemap_income,
        "JMamericanIndian": JusticeMap_americanIndian,
        "JMasian": JusticeMap_asian,
        "JMblack": JusticeMap_black,
        "JMmulti": JusticeMap_multi,
        "JMhispanic": JusticeMap_hispanic,
        "JMnonWhite": JusticeMap_nonWhite,
        "JMwhite": JusticeMap_white,
        "JMplurality": JusticeMap_plurality,
        "Clouds": clouds,
        "cloudsclassic": cloudscls,
        "precipitation": precipitation,
        "precipitation": precipitationcls,
        "rain": rain,
        "rain": raincls,
        "snow": snow,
        "pressure": pressure,
        "pressurecontour": pressurecntr,
        "temp": temp,
        "wind": wind,
        "Cities": city,
        "windrose": windrose
      };

      var hash = new L.Hash(map, allMapLayers);	   
          
    }   
    L.control.layers(baseMaps,overlayMaps).addTo(map);
   }
