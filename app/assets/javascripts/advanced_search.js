/**
  This javascript contains the page-specific functionality for the advanced search page.  This script is included via the tag on the advanced.html.erb page as follows:

  <% content_for (:head) { javascript_include_tag "advanced_search" } %>

  To expand on the capabilities, either add more script here or add the functionality to another script and add the values to the tag above.

**/

  jQuery(document).ready(function() {
  	//Set the search date format for the date pickers.
  	$('#search_min_date,#search_max_date').each(function() {
  		$(this).datepicker({
  			format: 'dd-mm-yyyy'
  		});
  	});
  });
