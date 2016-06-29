/**
  The restful_typeahead.js script provides generic typeahead functionality for the plots2 Rails app.
  The set of functions here are intended to provide a link between the data available through the RESTful 
  search API and the UI components.  
**/

//RESTful typeahead base URL
var typeaheadBase = '/api/typeahead/';
var idcount = 0;
var keycount = 0;
/**
  Set any input field with the id of 'srch-typeahead' to act as a typeahead field.  If the input field has the attribute 'srchGroup=[all | questions | profiles | notes]', then that particular method in the typeahead service is call.  Otherwise, it defaults to 'all'. 
**/
jQuery(document).ready(function() {
	$('input.search-query.typeahead').each(function() {
		setupApiSuggest(this);
	});

});

/**
  Perform the setup for the specified input element
**/
function setupApiSuggest(inelem) {
	var elemRef = $(inelem);
	var inid = elemRef.attr('id');
	//Check to see if the element is looking for a defined qry type; otherwise default to 'all'
	var ttype = 'all';
	var intype = elemRef.attr('qryType');
	if (intype) {
		ttype = intype;
	} else {
		//set the qryType attribute to 'all'
		elemRef.attr('qryType',ttype);
	}
	if (!inid) {
		//create a dynamic id if there is none
		idcount += 1;
		inid = 'srchInput_'+ttype+'_'+idcount;
		elemRef.attr('id',inid);
	}
	//Check that there is a datalist element--if not, create one
	var listid = elemRef.attr('list');
	var listelem = $('#'+listid);
	if (!listid) {
		//create a datalist
		listid = 'dlist_'+inid;
		var listhtml = '<datalist id="'+listid+'"></datalist>';
		listelem = $(listhtml).insertAfter(elemRef);
	}
	elemRef.on("keyup", function(e) {
		e.preventDefault();
		typeaheadSearch(this);
	});
}

/**
  Process the elements typed values and perform the query; display the results in the associated datalist
**/
function typeaheadSearch(srchElem) {
	var qtype = $(srchElem).attr('qryType');
	keycount += 1;
	var qparams = new Object();
	qparams.srchString = $(srchElem).val();
	qparams.seq = keycount;
	$.getJSON(typeaheadBase+qtype,qparams,function(qdata) {
		typeaheadResults(srchElem, qdata);
	});
}

/**
  Handle the return values for a typeahead call
**/
function typeaheadResults(ielem, resultsData) {

}
