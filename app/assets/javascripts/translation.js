$(document).ready(function () {
  $('.translationIcon').filter(function(i) {
  return (i + 1) % 3 == 0
  }).show();
});