/**
  The restful_typeahead.js script provides generic typeahead functionality for the plots2 Rails app.
  The set of functions here are intended to provide a link between the data available through the RESTful 
  search API and the UI components.  


* ensure 3 letters are typed before searching
* pressing enter on an option just loads that option
* clicking on an option just loads that option

**/

  //RESTful typeahead base URL
  var typeaheadBase = '/api/typeahead/';
  var idcount = 0;
  var minQry = 3;
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
    var intype = elemRef.attr('qrytype');
    if (intype) {
      ttype = intype;
    } else {
      //set the qrytype attribute to 'all'
      elemRef.attr('qrytype',ttype);
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
      //create a datalist <ul> HTML element
      listid = 'dlist_'+inid;
      elemRef.attr('data-results',listid);
      var inputtop = elemRef.position().top;
      var inputht = elemRef.outerHeight();
      var inputleft = elemRef.position().left;
      var listhtml = '<ul class="typeahead-results dropdown-menu" id="'+listid+'" style="display:none;"></ul>';
      listelem = $(listhtml).insertAfter(elemRef);
      listelem.css("top",inputtop+inputht);
      listelem.css("left",inputleft);
    }
    return listelem;
  }

  /**
    Set up to perform search on key stroke entries for the input element.  
    If "Enter" or "Esc" is the key stroke, then hide the typeahead.
  **/
  function typeaheadSearchKeys(ielem, reslist) {
    var elemRef = $(ielem);
    var listelem = $(reslist);
    elemRef.on("keyup", function(e) {
      e.preventDefault();
      var kcode = e.which || e.keyCode;
      if (kcode == 13 || kcode == 27) {
        //hit enter or escape, so hide the typeahead
        listelem.css("display","none");
      } else {
        typeaheadSearch(this);
      }
    });
  }

  /**
    Set up to perform tag search on key stroke entries for the input element. 
    If "Enter" or "Esc" is the key stroke, then hide the typeahead.
  **/
  function typeaheadTagKeys(ielem, reslist) {
    var elemRef = $(ielem);
    var listelem = $(reslist);
    elemRef.on("keyup", function(e) {
      e.preventDefault();
      var kcode = e.which || e.keyCode;
      if (kcode == 13 || kcode == 27) {
        //hit enter or escape, so hide the typeahead
        listelem.css("display","none");
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
      var dlist = $("#"+$(this).attr("data-results")).hide();
    });
  }

  /**
    Process the element's typed values and perform the query; 
    display the results in the associated datalist.
  **/
  function typeaheadSearch(srchElem) {
    var qtype = $(srchElem).attr('qrytype');
    keycount += 1;
    var qparams = new Object();
    qparams.srchString = $(srchElem).val();
    qparams.seq = keycount;
    //checks to reduce server load and minimize long return values
    if (!qparams.srchString) return;
    if (qparams.srchString == '' || qparams.srchString == ' ') return;
    if (qparams.srchString.length < minQry) return;
    $.getJSON(typeaheadBase + qtype, qparams, function(qdata) {
      if (qdata.srchParams) {
        if (qdata.srchParams.seq >= keycount) {    
          typeaheadTagList(srchElem, qdata);
        }
      }
    });
  }

  /**
    Handle the return values for a typeahead call
    THIS CODE WAS UNUSED - apparently we're only using typeaheadTagList?
  **/
/*
  function typeaheadDocList(ielem, docList) {
    var elemRef = $(ielem);
    var elemList = $('#'+elemRef.attr('data-results'));
    elemList.html('');
    if (docList.items) {
      for (var i = 0; i < docList.items.length; i++) {
        var val = docList.items[i].docVal;
        var type = docList.items[i].docType;
        var url = docList.items[i].docUrl;
        var listopt = $('<li data-url="' + url + '" data-text="' + val + '"><a href="#"><i class="fa fa-' + type + '"></i>&nbsp;' + val + '</a></li>');
        listopt.on('mousedown', clickTypeaheadItem);
        elemList.append(listopt);
      }
    }
    //elemList.toggleClass('results-noshow',false);
    elemList.css("display","block");
  }
*/

  /**
    Handle a click on one of the displayed suggestions in the typeahead "dropdown"
    We actually just use URLs here, but in case the <a> element doesn't get a click
  **/
  function clickTypeaheadItem(e) {
    e.preventDefault();
    window.location = $(this).attr('data-url');
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
      var inputtop = elemRef.position().top;
      var inputht = elemRef.outerHeight();
      var inputleft = elemRef.position().left;
      var listhtml = '<ul class="typeahead-results dropdown-menu" id="'+listid+'" style="display:none;"></ul>';
      listelem = $(listhtml).insertAfter(elemRef);
      listelem.css("top",inputtop+inputht);
      listelem.css("left",inputleft);
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
    if (qparams.srchString.length < minQry) return;
    $.getJSON(typeaheadBase+'tags', qparams, function(qdata) {
      if (qdata.srchParams) {
        if (qdata.srchParams.seq >= keycount) {    
          typeaheadTagList(tagElem, qdata);
        }
      }
    });
  }

  /**
    Handle the return values for a typeahead call by
    inserting them into the <ul> datalist
  **/
  function typeaheadTagList(ielem, tagList) {
    var elemRef = $(ielem);
    var elemList = $('#'+elemRef.attr('data-results'));
    elemList.html('');
    if (tagList.items) {
      for (var i=0;i<tagList.items.length;i++) {
        var val = tagList.items[i].tagVal;
        var type = tagList.items[i].tagType;
        var url = tagList.items[i].tagSource || '/tag/' + val;
        var listopt = $('<li data-url="' + url + '" data-text="' + val + '"><a href="' + url + '"><i class="fa fa-' + type + '"></i>&nbsp;' + val + '</a></li>');
        listopt.on('mousedown', clickTypeaheadItem);
        elemList.append(listopt);
      }
      $(elemList).find('li').mousedown(clickTypeaheadItem);
    }
    if (tagList.items.length > 0) elemList.css("display","block");
    else elemList.css("display","none");
  }


