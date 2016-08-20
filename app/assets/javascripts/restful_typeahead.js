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
    This call performs two setup operations in support of typeahead usage.  The usage is separated by the organization of the data that is returned.  General document typeahead searches return a 'docList', which is a list of document data and their URLs (not used in typeahead functionality at this time).  Conversely, that tag searches/suggestions return tag data, which can be associated with multiple URLs, and is thus less specific but could be more informative.
    First, set any input field with the classes of 'search-query' and 'typeahead' to act as a typeahead field.  If the input field has the attribute 'srchGroup=[all | questions | profiles | notes]', then that particular method in the typeahead service is called.  Otherwise, it defaults to 'all'.
    Second, set any input field with the  classes of 'search-query' and 'tagsrch' to act as a tag-centric typeahead field.
  **/
  jQuery(document).ready(function() {
	$('input.search-query.typeahead').each(function() {
		var resultList = setupSrchSuggest(this);
		typeaheadSearchKeys(this, resultList);
		hideResultsOnBlur(this, resultList);
	});
	$('input.search-query.tagsrch').each(function() {
		var resultList = setupTagSuggest(this);
		typeaheadTagKeys(this, resultList);
		hideResultsOnBlur(this, resultList);
	});
  });

  /**
    Perform the suggest search setup for the specified input element.  
    Returns a reference (jQuery object) for the associated list element
  **/
  function setupSrchSuggest(inelem) {
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
	var listid = elemRef.attr('data-results');
	var listelem = $('#'+listid);
	if (!listid) {
		//create a datalist
		listid = 'dlist_'+inid;
		elemRef.attr('data-results',listid);
		var listhtml = '<ul class="typeahead-results results-noshow" id="'+listid+'"></ul>';
		listelem = $(listhtml).insertAfter(elemRef);
	}
	return listelem;
  }

  /**
    Set up to perform search on key stroke entries for the input element.  If "Enter" or "Esc" is the key stroke, then hide the typeahead.
  **/
  function typeaheadSearchKeys(ielem, reslist) {
        var elemRef = $(ielem);
        var listelem = $(reslist);
	elemRef.on("keyup", function(e) {
		e.preventDefault();
		var kcode = e.which || e.keyCode;
		if (kcode == 13 || kcode == 27) {
			//hit enter or escape, so hide the typeahead
			listelem.toggleClass('results-noshow',true);
		} else {
			typeaheadSearch(this);
		}
	});
  }

  /**
    Set up to perform tag search on key stroke entries for the input element.  If "Enter" or "Esc" is the key stroke, then hide the typeahead.
  **/
  function typeaheadTagKeys(ielem, reslist) {
	var elemRef = $(ielem);
	var listelem = $(reslist);
	elemRef.on("keyup", function(e) {
		e.preventDefault();
		var kcode = e.which || e.keyCode;
		if (kcode == 13 || kcode == 27) {
			//hit enter or escape, so hide the typeahead
			listelem.toggleClass('results-noshow',true);
		} else {
			typeaheadTags(this);
		}
	});

  }

  /**
    On lost focus (blur) of the input element, hide the result list
  **/
  function hideResultsOnBlur(ielem, resList) {
	var elemRef = $(ielem);
	var listelem = $(resList);
        elemRef.on("blur", function(e) {
		listelem.toggleClass('results-noshow',true);
	});
  }

  /**
    Process the element's typed values and perform the query; display the results in the associated datalist
  **/
  function typeaheadSearch(srchElem) {
	var qtype = $(srchElem).attr('qryType');
	keycount += 1;
	var qparams = new Object();
	qparams.srchString = $(srchElem).val();
	qparams.seq = keycount;
	$.getJSON(typeaheadBase+qtype,qparams,function(qdata) {
		if (qdata.srchParams) {
			if (qdata.srchParams.seq >= keycount) {		
				typeaheadTagList(srchElem, qdata);
			}
		}
	});
  }

  /**
    Handle the return values for a typeahead call
  **/
  function typeaheadDocList(ielem, docList) {
	var elemRef = $(ielem);
	var elemList = $('#'+elemRef.attr('data-results'));
	elemList.html('');
	if (docList.items) {
		for (var i=0;i<docList.items.length;i++) {
			var listopt = $('<li data-text="'+docList.items[i].docTitle+'"><span class="fa fa-'+docList.items[i].docType+'"></span>&nbsp;'+docList.items[i].docTitle+'</li>');
			listopt.on('mousedown',function(e) {
				e.preventDefault();
				elemRef.val($(this).attr('data-text'));
				elemList.toggleClass('results-noshow',true);
			});
			elemList.append(listopt);
		}
	}
	elemList.toggleClass('results-noshow',false);
  }

  /**
    Set up the tag search function for the given element
  **/
  function setupTagSuggest(inelem) {
	var elemRef = $(inelem);
	var inid = elemRef.attr('id');
	if (!inid) {
		//create a dynamic id if there is none
		idcount += 1;
		inid = 'tagInput_'+idcount;
		elemRef.attr('id',inid);
	}
	//Check that there is a datalist element--if not, create one
	var listid = elemRef.attr('data-results');
	var listelem = $('#'+listid);
	if (!listid) {
		//create a datalist
		listid = 'dlist_'+inid;
		elemRef.attr('data-results',listid);
		var listhtml = '<ul class="typeahead-results results-noshow" id="'+listid+'"></ul>';
		listelem = $(listhtml).insertAfter(elemRef);
	}
	return listelem;
  }

  /**
    Process the element's typed values and perform the tag query; display the results in the associated datalist
  **/
  function typeaheadTags(tagElem) {
	keycount += 1;
	var qparams = new Object();
	qparams.srchString = $(tagElem).val();
	qparams.seq = keycount;
	$.getJSON(typeaheadBase+'tags',qparams,function(qdata) {
		if (qdata.srchParams) {
			if (qdata.srchParams.seq >= keycount) {		
				typeaheadTagList(tagElem, qdata);
			}
		}
	});
  }

  /**
    Handle the return values for a typeahead call
  **/
  function typeaheadTagList(ielem, tagList) {
	var elemRef = $(ielem);
	var elemList = $('#'+elemRef.attr('data-results'));
	elemList.html('');
	if (tagList.items) {
		for (var i=0;i<tagList.items.length;i++) {
			var listopt = $('<li data-text="'+tagList.items[i].tagVal+'"><span class="fa fa-'+tagList.items[i].tagType+'"></span>&nbsp;'+tagList.items[i].tagVal+'</li>');
			listopt.on('mousedown',function(e) {
				e.preventDefault();
				elemRef.val($(this).attr('data-text'));
				elemList.toggleClass('results-noshow',true);
			});
			elemList.append(listopt);
		}
	}
	elemList.toggleClass('results-noshow',false);
  }

  /**
    Set the value for the data item into the given element
  **/
  //function dataListClick(ielem, optval) {
  //	$(ielem).val(optval);
  //        $(ielem).parent().toggleClass('results-noshow',true);
  //}

