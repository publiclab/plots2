(function() {

  var types = {
    'note':     true, 
    'question': true, 
    'event':    true, 
    'comment':  true, 
    'wiki':     true
  };

  var setTypeVisibility = function(type, checked) {

    if (checked) {

      $('.note-container-' + type).show();

    } else {

      $('.note-container-' + type).hide();

    }

    $('.activity .col-md-6:visible:even').css('clear', 'left');

    if (localStorage) {

      types[type] = (checked == true);
      localStorage.setItem('pl-dash-' + type, checked);
      $('.node-type-' + type).prop('checked', checked);

    }

    if ($('.activity-dropdown input.node-type:checked').length < $('.activity-dropdown input.node-type').length) {

      $('.activity-dropdown .dropdown-toggle .node-type-filter').html('Selected updates');

    } else {

      $('.activity-dropdown .dropdown-toggle .node-type-filter').html('All updates');

    }

  }

  // load any settings from browser storage
  if (localStorage) {

    Object.keys(types).forEach(function(key, i) {

      var type = types[key];
      if (localStorage.getItem('pl-dash-' + key) == null) localStorage.setItem('pl-dash-' + key, true);
      types[key] = localStorage.getItem('pl-dash-' + key) == "true",
      setTypeVisibility(key, types[key]);

    });

  }

  $('.activity-dropdown .dropdown-toggle').click(function(e) {

    e.preventDefault();

  });

  $('.activity-dropdown input').click(function() {

    setTypeVisibility($(this).attr('data-type'), $(this).prop('checked'));

  });


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
      url:   '/lists'
    },
    'publiclaboratory': {
      feed:  '/home/fetch?url=https://groups.google.com/forum/feed/publiclaboratory/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'grassrootsmapping': {
      feed:  '/home/fetch?url=https://groups.google.com/forum/feed/grassrootsmapping/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-spectrometry': {
      feed:  '/home/fetch?url=https://groups.google.com/forum/feed/plots-spectrometry/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-infrared': {
      feed:  '/home/fetch?url=https://groups.google.com/forum/feed/plots-infrared/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-airquality': {
      feed:  '/home/fetch?url=https://groups.google.com/forum/feed/plots-airquality/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-waterquality': {
      feed:  '/home/fetch?url=https://groups.google.com/forum/feed/plots-waterquality/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
    'plots-dev': {
      feed: '/home/fetch?url=https://groups.google.com/forum/feed/plots-dev/topics/rss.xml?num=15',
      url:   '/lists#publiclaboratory'
    },
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
        if (list != 'combined') metaEl.find('.date').append(' on <a href="' + lists[list].url + '">' + list + '</a>');

      });

      if (lists[list].feed.match('https://groups.google.com')) {

        $('.lists').append('<p><a href="https://groups.google.com/forum/#!forum/' + list + '">More list topics &raquo;</a></p>');

      }

    });

  }

  $('a.lists-tab').on('shown.bs.tab', function() { show_list('combined'); });

  $('.list-select').change(function() { show_list($(this).val()); });

})();
