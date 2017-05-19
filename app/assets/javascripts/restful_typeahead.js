/**
  The restful_typeahead.js script provides generic typeahead functionality for the plots2 Rails app.
  The set of functions here are intended to provide a link between the data available through the RESTful 
  search API and the UI components.  
**/

jQuery(document).ready(function() {
  var typeahead = $('input.search-query.typeahead').typeahead({
    items: 8,
    minLength: 3,
    source: function (query, process) {
      return $.get('/api/typeahead/all?srchString=' + query, function (data) {
        return process(data.items);
      },'json');
    },
    displayText: function(item) {
      return item.tagVal;
    },
    updater: function(text) { 
console.log(text);
      el.find('input.search-query.typeahead').val(text);
      el.submit();
    }
  });
});
