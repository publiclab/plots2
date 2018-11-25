/* eslint-disable complexity */
/* eslint-disable wrap-iife */


(function() {

  var types = {
    'all':      true,
    'note':     true, 
    'question': true, 
    'event':    true, 
    'comment':  true
  };

  

  var viewport = function() {
    var e = window, a = 'inner';
    if (!('innerWidth' in window )) {
      a = 'client';
      e = document.documentElement || document.body;
    }
    return { width : e[ a+'Width' ] , height : e[ a+'Height' ] };
  }

  if(!viewport().width > 992) {
    types.wiki = true;
  }

  var setTypeVisibility = function(type, checked) {    
    var filterTypes = [];
    for(var i = 0; i < type.length; i++) {
        if(checked[i]) filterTypes.push(type[i]);
    }
    var baseurl = window.location.href;
    url = new URL(baseurl);

    if(filterTypes.length > 0 || (baseurl.indexOf('types=') > -1)) {
      url.searchParams.set("types", filterTypes);
      window.location.href = url;
    }
  }

  var getLocalStorageActivity = function() {  

    if (localStorage) {
 
      Object.keys(types).forEach(function(key, i) {
 
        var type = types[key];
        if (localStorage.getItem('pl-dash-' + key) === null) localStorage.setItem('pl-dash-' + key, true);
        types[key] = localStorage.getItem('pl-dash-' + key) === "true"
        $('.activity-dropdown li.filter-checkbox').find('[data-type='+ key +']').prop('checked', types[key]); 
      });
 
    }

  }

  getLocalStorageActivity();


  // allow native stylesheets to determine visibility on 
  $(window).on('resize', function() {

    $('.activity .col-md-6').css('display', '');
    getLocalStorageActivity();

  });


  $('.activity-dropdown .dropdown-toggle').click(function(e) {

  });

  $('.activity-dropdown a').click(function(e) {
    e.preventDefault();
    // use CSS clear:left to tidy columns 
    $('.activity .col-md-6').css('clear', 'none');
    $('.activity .col-md-6:visible:even').css('clear', 'left');

    updateDropdownTitle();
  });

  

  function updateFilters() {
    var types = [];
    var checked = [];
    $('.activity-dropdown li.filter-checkbox').each(function () {
      var type = $(this).find('input').attr('data-type');
      var ischecked = $(this).find('input').prop('checked');
      if(!ischecked && types[0] === 'all') {
        checked[0] = false;
      }
      if(type !== 'wiki') {
        types.push(type);
        checked.push(ischecked);
      }
      else if(!(viewport().width > 992)) {
        types.push(type);
        checked.push(ischecked);
      }
    });

    var valuesAfterAdditionToStorage = addCheckboxValuesToLocalStorage(types, checked);
    types = valuesAfterAdditionToStorage.types;
    values = valuesAfterAdditionToStorage.values;
    updateDropdownTitle();
    setTypeVisibility(types, checked);
  }

  function addCheckboxValuesToLocalStorage(types, checked) {
    types.forEach(function(element, index) {
      var type = element;
      var ischecked = checked[index];
      if(index === 0 && checked.slice(1, checked.length).every(x => x)) {
        ischecked = true;
        checked[index] = true;
      }
      if (localStorage) {
        localStorage.setItem('pl-dash-' + type, ischecked);
        $('.node-type-' + type).prop('checked', ischecked);
      }
    });

    return {
      types, checked
    }
  }

  $('.activity-dropdown li').click(function(e) {
    e.stopPropagation();
    if($(this).find('input').attr('data-type') === 'all') {
      var all = this
      $('.activity-dropdown li.filter-checkbox').each(function () {
        $(this).find('input').prop('checked', $(all).find('input').prop('checked'));
      });
    }
    updateFilters();
    
  });

  function updateDropdownTitle() {
    if ($('.activity-dropdown input.node-type:checked').length < $('.activity-dropdown input.node-type').length) {
      $('.activity-dropdown .dropdown-toggle .node-type-filter').html(I18n.t('js.dashboard.selected_updates'));
    } else if ($('.activity-dropdown input.node-type:checked').length === 0) {
      $('.activity-dropdown .dropdown-toggle .node-type-filter').html(I18n.t('js.dashboard.none'));
    } else {
      $('.activity-dropdown .dropdown-toggle .node-type-filter').html(I18n.t('js.dashboard.all_updates'));
    }
  }


  $('.note-wiki, .wikis .wiki').each(function(wiki) {

    var wikiEl = $(this),
        index  = wikiEl.attr("data-index"),
        a      = wikiEl.find(".wiki-diff-" + index).attr("data-diff-a"),
        b      = wikiEl.find(".wiki-diff-" + index).attr("data-diff-b");

    $(this).find(".btn-diff-" + index).click(function() {

      var btn = this;

      wikiEl.find(".wiki-diff-" + index).show();
      wikiEl.find(".wiki-diff-" + index).load("/wiki/diff/?a=" + a + "&b=" + b, function() {

        wikiEl.find(".wiki-diff-" + index).prepend('<p class="header"><b>Changes in this edit:</b></p>');

        $(btn).off('click');
        $(btn).click(function() {

        wikiEl.find(".wiki-diff-" + index).toggle();

      });

      });

    });

  });


  // (must be https)
  // should adapt so we can store the "home" url of each feed, for click-through.
  // so, { title: '', feed: '', url: '' }
  var lists = {
    'test': {
      feed:  '/feed.rss',
      url:   '/'
    },
    'combined': {
      feed:  '/home/fetch?url=https://feeds.feedburner.com/rssmixer/ZvcX',
      //feed:  'https://publiclab.org/rssproxy/combined/',
      url:   '/lists'
    },
    'publiclaboratory': {
      feed:  'https://publiclab.org/rssproxy/publiclaboratory/',
      //feed:  '/home/fetch?url=https://groups.google.com/forum/feed/publiclaboratory/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'grassrootsmapping': {
      feed:  'https://publiclab.org/rssproxy/grassrootsmapping/',
      //feed:  '/home/fetch?url=https://groups.google.com/forum/feed/grassrootsmapping/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-spectrometry': {
      feed:  'https://publiclab.org/rssproxy/plots-spectrometry/',
      //feed:  '/home/fetch?url=https://groups.google.com/forum/feed/plots-spectrometry/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-infrared': {
      feed:  'https://publiclab.org/rssproxy/plots-infrared/',
      //feed:  '/home/fetch?url=https://groups.google.com/forum/feed/plots-infrared/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-airquality': {
      feed:  'https://publiclab.org/rssproxy/plots-airquality/',
      //feed:  '/home/fetch?url=https://groups.google.com/forum/feed/plots-airquality/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-waterquality': {
      feed:  'https://publiclab.org/rssproxy/plots-waterquality/',
      //feed:  '/home/fetch?url=https://groups.google.com/forum/feed/plots-waterquality/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-dev': {
      feed: 'https://publiclab.org/rssproxy/plots-dev/',
      //feed: '/home/fetch?url=https://groups.google.com/forum/feed/plots-dev/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    }
  };

  var show_list = function (list) {

    $.get(lists[list].feed, function (feed) {
 
      $('.lists').html('');
 
      $.each($(feed).find('channel item').slice(0, 10), function (i, item) { 
 
        $('.lists').append('<div class="feed-item-' + i + '"></div>');
  
        var itemEl       = $('.lists .feed-item-' + i),
            title        = $(item).find('title').html(),
            link         = $(item).find('link').html(),
            author       = $(item).find('author').html(),
            pubDate      = $(item).find('pubDate').html(),
            description  = $(item).find('description').html();
  
        pubDate = moment(new Date(pubDate)).fromNow();
  
        itemEl.append('<h4 class="title"></h4>');
        itemEl.find('.title').append('<a></a>');
        itemEl.find('.title a').attr('href', link);
        itemEl.find('.title a').append(title);
 
        itemEl.append('<p class="meta"></p>');
        var metaEl = $('.lists .meta:last');
  
        metaEl.append('<i class="fa fa-envelope-o"></i> ');
        metaEl.append('<span class="date"></span>');
        metaEl.find('.date').append(pubDate);

        if (author) metaEl.find('.date').append(' by <i>' + author + '</i>');
        if (list !== 'combined') metaEl.find('.date').append(' on <a href="' + lists[list].url + '">' + list + '</a>');

      });

      if (lists[list].feed.match('https://groups.google.com')) {

        $('.lists').append('<p><a href="https://groups.google.com/forum/#!forum/' + list + '">More list topics &raquo;</a></p>');

      }

    });

  }

  $('a.lists-tab').on('shown.bs.tab', function() { show_list('combined'); });

  $('.list-select').change(function(e) { 

    show_list($(this).val());

  });

  $('.search-form-wiki').submit(function(e){ 

    e.preventDefault();
    window.location = '/search/' + $('.search-form-wiki input').val();

  })

  $(function () {
    var url_string = window.location.href;
    var url = new URL(url_string);
    var params = url.searchParams.get("types");
    updateDropdownTitle();
    
    if(params !== null) {
      params = params.split(",");
    }

  });

})();
