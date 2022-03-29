$(document).ready(function () {
  // display only every 3rd translation prompt, and stop when we reach 10
  $('.translationIcon').filter(function(i) {
    var maxTranslationPrompts = 20
    return (i + 1) % 3 === 0 && i < maxTranslationPrompts / 3
  }).show();
});
