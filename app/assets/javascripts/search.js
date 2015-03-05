$('#searchform').submit(function(e){ 
  e.preventDefault()
  window.location = '/search/'+$('#searchform_input').val()
})
// working off of http://stackoverflow.com/questions/9232748/twitter-bootstrap-typeahead-ajax-example
$('#searchform_input').typeahead({
  source: function (typeahead, query) {
    if (query.length > 2) {
      return $.post('/search/typeahead/'+query, {}, function (data) {
        return typeahead.process(data)
      })
    }
  },
  items: 15,
  //highlighter: function(a) {a},
  autoselect: false,
  autowidth: false,
  menu: '<ul id="searchtypeahead" class="typeahead dropdown-menu"></ul>'
})
