function makeExpandingArea(container) {
  var area = container.find("textarea");
  var span = container.find("span");
  area.on('input propertychange', function() {
    span.text(area.val());
  });
  span.text(area.val());
 
  // Enable extra CSS
  container.addClass("active");
}

$('.expandingArea').each(function(){
  makeExpandingArea($(this));
})
