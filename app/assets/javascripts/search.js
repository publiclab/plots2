jQuery(document).ready(function() {

  $('#searchform').submit(function(e){ 
    e.preventDefault()
    window.location = '/search/'+$('#searchform_input').val()
  })

  var typeaheadSearchResults = {};

  $('#searchform_input').typeahead({
    items: 15,
    minLength: 3,
    source: function (query, process) {
      return $.post('/search/typeahead/'+query, {}, function (data) {
        return process(data);
      })
    },
    updater: function(item) {
      var url;
      if ($(item)[0] != undefined) url = $(item)[0].attributes['data-url'].value;
      else url = '/search/'+$('#searchform_input').val();
      window.location = url;
    }
  })

})
