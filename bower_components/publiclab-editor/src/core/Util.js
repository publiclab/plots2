module.exports = {

  getUrlHashParameter: function(sParam) {

    var sPageURL = window.location.hash;
    if (sPageURL) sPageURL = sPageURL.split('#')[1];
    var sURLVariables = sPageURL.split('&');

    for (var i = 0; i < sURLVariables.length; i++) {

      var sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] == sParam) {
        return sParameterName[1];
      }

    }

  },

  getUrlParameter: function(sParam) {

    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');

    for (var i = 0; i < sURLVariables.length; i++) {

      var sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] == sParam) {
        return sParameterName[1];
      }

    }

  }

}
