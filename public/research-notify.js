//Bookmarklet: javascript:(function(){document.body.appendChild(document.createElement('script')).src='https://gist.githubusercontent.com/jywarren/c21a3d6beb5f1e8d4f50/raw/115c2459f2c4d6e43dd1e1f369a4f2d0313601e9/research-notify.js';})()

//Nice tips on jquery inclusion etc here: http://www.smashingmagazine.com/2010/05/23/make-your-own-bookmarklets-with-jquery/

function getSelText() {
  var SelText = '';
  if (window.getSelection) {
    SelText = window.getSelection();
  } else if (document.getSelection) {
    SelText = document.getSelection();
  } else if (document.selection) {
    SelText = document.selection.createRange().text;
  }
  return SelText;
}

(function(){

  // the minimum version of jQuery we want
  var v = "1.3.2";

  // check prior inclusion and version
  if (window.jQuery === undefined || window.jQuery.fn.jquery < v) {
    var done = false;
    var script = document.createElement("script");
    script.src = "http://ajax.googleapis.com/ajax/libs/jquery/" + v + "/jquery.min.js";
    script.onload = script.onreadystatechange = function(){
      if (!done && (!this.readyState || this.readyState == "loaded" || this.readyState == "complete")) {
        done = true;
        initMyBookmarklet();
      }
    };
    document.getElementsByTagName("head")[0].appendChild(script);
  } else {
    initMyBookmarklet();
  }
  
  function initMyBookmarklet() {
    (window.myBookmarklet = function() {
      // your JavaScript code goes here!
      
      
      $('body')[0].onmouseup = function(e) {
        window.location = "http://publiclab.org/post?title="+$('#title').text()+"&body="+getSelText()
      }

      alert("Drag to select the content you want to open source at PublicLab.org")

    })();
  }

})();