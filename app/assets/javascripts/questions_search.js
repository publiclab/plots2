// These changes are temporary for implementing question based search functionality
// To be removed or modified accordingly by Advanced Search Project

jQuery(document).ready(function(){

	$('.typeahead.dropdown-menu li').addClass('col-xs-12');
	$('#questions_searchform').submit(function(e){ 
    e.preventDefault()
    window.location = '/questions_search/' + $('#questions_searchform_input').val()
  })

  $('#questions_searchform_input').typeahead({
    items: 15,
    minLength: 3,
    source: function (query, process) {
      return $.post('/questions_search/typeahead/' + query, {}, function (data) {
        return process(data);
      })
    },
    updater: function(item) {
      var url;
      if ($(item)[0] != undefined) url = $(item)[0].attributes['data-url'].value;
      else url = '/questions_search/' + $('#questions_searchform_input').val();
      window.location = url;
    }
  })
})