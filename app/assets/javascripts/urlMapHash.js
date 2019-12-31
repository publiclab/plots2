function urlMapHash() {
  // This is based off of jywarren's urlhash, made specific to our map hash needs

  const paramArray = ["zoom", "lat", "lon"];
  
  function getUrlHashParameter(param) {
  
    var params = getUrlHashParameters();
    return params[param];
  
  }
  
  function getUrlHashParameters() {
  
    var sPageURL = window.location.hash;
    if (sPageURL) sPageURL = sPageURL.split('#')[1];
    var items = sPageURL.split('/');
    var object = {};
    items.forEach(function(item, i) {
      if ((item !== '') && (paramArray[i])) object[paramArray[i]] = item;
    });
    return object;
  }
  
  // accepts an object like { paramName: value, paramName1: value }
  // and transforms to: url.com#zoom/lat/lon
  function setUrlHashParameters(params) {
  
    var values = [];
    paramArray.forEach(function(key, i) {
      values.push(params[key]);
    });
    var hash = values.join('/');
    window.location.hash = hash;
  
  }
  
  function setUrlHashParameter(param, value) {
  
    var params = getUrlHashParameters();
    params[param] = value;
    setUrlHashParameters(params);
  
  }
  
  return {
    getUrlHashParameter:   getUrlHashParameter,
    getUrlHashParameters:  getUrlHashParameters,
    setUrlHashParameter:   setUrlHashParameter,
    setUrlHashParameters:  setUrlHashParameters
  }
    
}