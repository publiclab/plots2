/**
  This script holds the functionality for the dynamic search forms, using the RESTful API and new search classes
  under development by the Advanced Search Project.
**/
//URL for search queries
var srchBase = "/api/srch/all";
//Number of searches conducted--used to manage display flow
var srchCount = 0;
//array of mapping objects to coordinate displays
var tabDataArray = [
	{ qryType: "file", tabId: "#tabnotes", countspan: "#notecount"},
	{ qryType: "tag", tabId: "#tabtags", countspan: "#tagcount"},
	{ qryType: "map", tabId: "#tabmaps", countspan: "#mapcount"},
	{ qryType: "user", tabId: "#tabprofiles", countspan: "#profilecount"},
	{ qryType: "book", tabId: "#tabstatic", countspan: "#staticcount"},
	{ qryType: "question-circle", tabId: "#tabquestions", countspan: "#questioncount"}
	];


/**
  Setup for dynamic search
**/
jQuery(document).ready(function() {
	//for now, prevent submission of the query form--all restful at this point
	jQuery("#dynamic_srch_form").submit(function(e) {
		e.preventDefault();
		dynamicSearch();
	});
	var qfield = $("#qryField");
	var qryList = setupSrchSuggest(qfield);
	dynamicSearchKeys(qfield, qryList);
	hideResultsOnBlur(qfield, qryList);
});

/**
  Set up the dynamic search and typeahead suggest for this particular element.  The following key strokes cause the following actions:
  1)  ENTER (KeyCode = 13):  perform dynamic search, hide typeahead
  2)  ESC (KeyCode = 27):  hide typeahead
  3)  SPACE (KeyCode = 32):  perform dynamic search, do not hide typeahead
  4)  Any other key:  perform typeahead search, show suggestion list (if not visible)
**/
function dynamicSearchKeys(ielem, reslist) {
	var elemRef = $(ielem);
	var listelem = $(reslist);
	elemRef.on("keyup", function(e) {
		e.preventDefault();
		var kcode = e.which || e.keyCode;
		switch(kcode) {
			case 27:
				//hit escape, so hide the typeahead
				listelem.toggleClass('results-noshow',true);
				break;
			case 13:
				//hit enter, so hide typeahead results and run search
				dynamicSearch(this);
				listelem.toggleClass('results-noshow',true);
				break;
			case 32:
				//space bar--run search
				dynamicSearch(this);
				break;
			default:
				//general typing--perform suggestion routine
				typeaheadSearch(this);
				break;
		}
	});
}

/**
  Execute the live search function
**/
function dynamicSearch(inputElem) {
	srchCount += 1;
        var srchParams = searchParams(inputElem);
	//don't send nulls or empty strings
        if (srchParams.srchString && srchParams.srchString != '') {
	        $.getJSON(srchBase, srchParams, function(sdata) {
			parseDynamicSearch(sdata);
		});
	}
}

/**
  Collect up the search parameters and return a search object to be submitted
**/
function searchParams(inputElem) {
  var sparms = {};
  var stxt = $(inputElem).val();
  if (stxt) {
	  sparms.srchString = stxt.trim();
  }
  sparms.seq = srchCount;
  sparms.showCount = 25;
  sparms.pageNum = 0;
  return sparms;
}

/**
  Parse out the results of the live search and display accordingly
**/
function parseDynamicSearch(doclist) {
	if (doclist) {
		//if (doclist.seq >= srchCount) {
			clearResults();
			//First, display in the "all" tab
			var currtab = $('#taball');
			var currcount = $('#allcount');
			var currres = currtab.find('div.row.sresults-row');
			var rescon = resultContainer();
			currcount.text(doclist.items.length);
			for (var i=0;i<doclist.items.length;i++) {
				rescon.append($(docPanel(doclist.items[i])));
			}
			currres.append(rescon);
			//Now walk through the array of tabs
			for (var j=0;j<tabDataArray.length;j++) {
				var currtype = tabDataArray[j].qryType;
				var docarray = [];				
				for (var k=0;k<doclist.items.length;k++) {
					if (doclist.items[k].docType == currtype) docarray.push(doclist.items[k]);
				}
				currtab = $(tabDataArray[j].tabId);
				currcount = $(tabDataArray[j].countspan);
				currres = currtab.find('div.row.sresults-row');
				currcount.text(docarray.length);
				rescon = resultContainer();
				for (var m=0;m<docarray.length;m++) {
					rescon.append($(docPanel(docarray[m])));
				}
				currres.append(rescon);
			}
		//}
	}
}

function resultContainer() {
	return $("<div class='panel-group'></div>");
}

/**
  Create a row result item from the document
  TODO:  Better way to create these?
**/
function docPanel(docitem) {
	var iconclass = "fa fa-"+docitem.docType;
	var doclink = "<a href='"+docitem.docUrl+"'>"+docitem.docTitle+"</a>";
	var dtxt = "<div class='panel panel-default'>";
	dtxt += "<div class='panel-heading'><span class='"+iconclass+"'></span>"+doclink+"</div>";
	dtxt += "<div class='panel-body'>";
	dtxt += (docitem.docSummary && docitem.docSummar != '' ? docitem.docSummary : 'No summary available'); 
	dtxt += "</div>";
	dtxt += "</div>";
	return dtxt;
}

function clearResults() {
	for (var i=0;i<tabDataArray.length;i++) {
		$(tabDataArray[i].tabId).find('div.row.sresults-row').html('');
	}
}

/**
 Provides prev/next button functionality.  Originally from http://bootsnipp.com/snippets/7NyNP
**/
$(function(){
    $('.nav-tabs a:first',this.$page).tab('show')
    $('.nav-tabs li:gt(0)',this.$page).each(function(){
        $(this).addClass('disabled');
        $('a',$(this)).attr('data-toggle','');
    });
    
    $('.next-tab').on('click',function(){
        var $panel = $(this).closest('.panel');
        var $tabs = $('.nav-tabs li',$panel);
        var $tab = $('.nav-tabs li.active',$panel);
        var index  = $tabs.index($tab);
        if (index < 0) {
            return; //no hope for you!
        }
        index++;
        var $next_tab = $('a',$tabs.eq(index));
        if (!$next_tab.length) {
            return;
        }
        $next_tab.parents('li').removeClass('disabled');
        $next_tab.attr('data-toggle','tab');
        $next_tab.tab('show');
    });
    $('.previous-tab').on('click',function(){
        var $panel = $(this).closest('.panel');
        var $tabs = $('.nav-tabs li',$panel);
        var $tab = $('.nav-tabs li.active',$panel);
        var index  = $tabs.index($tab);
        if (index < 0) {
            return; //no hope for you!
        }
        index--;
        var $previous_tab = $('a',$tabs.eq(index));
        if (!$previous_tab.length) {
            return;
        }
        $previous_tab.parents('li').removeClass('disabled');
        $previous_tab.data('toggle','tab');
        $previous_tab.tab('show');    });
    
});
