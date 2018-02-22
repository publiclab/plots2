module.exports = function onFail(response, uniqueId) {
  var message = $('#' + uniqueId + ' .section-message');
  message.html('There was an error -- the wiki page may have changed while you were editing; save your content in the clipboard and try refreshing the page.');
}
