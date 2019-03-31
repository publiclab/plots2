/**
  The restful_typeahead.js script provides generic typeahead functionality for the plots2 Rails app.
  The set of functions here are intended to provide a link between the data available through the RESTful
  search API and the UI components.
  Documentation here: https://github.com/bassjobsen/Bootstrap-3-Typeahead
**/

$(function() {
  $('input.search-query.typeahead').each(function(i, el){
    var typeahead = $(el).typeahead({
      items: 10,
      minLength: 3,
      showCategoryHeader: true,
      autoSelect: false,
      source: debounce(function (query, process) {
        var encoded_query = encodeURIComponent(query);
        var qryType = $(el).attr('qryType');
        return $.getJSON('/api/srch/' + qryType + '?query=' + encoded_query, function (data) {
          return process(data.items);
        },'json');
      }, 350),
      highlighter: function (text, item) {
        return item.doc_title;
      },
      matcher: function() {
        return true;
      },
      displayText: function(item) {
        return item.doc_title;
      },
      updater: function(item) {
        if (item.hasOwnProperty('showAll') && item.showAll) {
          var query = this.value;
          window.location = window.location.origin + "/search/" + query;
        }
        else if (item.hasOwnProperty('doc_url') && item.doc_url) {
          window.location = window.location.origin + item.doc_url;
        } else {
          window.location = window.location.origin + '/tag/' + item.doc_title;
        }
        item = item.doc_title;
        return item;
      },
      addItem: { doc_title: 'View all',
                 showAll: true
               }
    });
  });
});
