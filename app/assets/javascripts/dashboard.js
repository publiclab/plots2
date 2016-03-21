(function() {

  // must be https
  // 'http://rssmixer.com/feed/2851.xml'
  // cors? http://cors.io/?u=https://groups.google.com/forum/feed/publiclaboratory/topics/rss.xml?num=15
  var lists = {
    'test':               '/feed.rss',
    'combined':           'https://feeds.feedburner.com/rssmixer/ZvcX',
    'publiclaboratory':   'https://groups.google.com/forum/feed/publiclaboratory/topics/rss.xml?num=15',
    'grassrootsmapping':  'https://groups.google.com/forum/feed/grassrootsmapping/topics/rss.xml?num=15',
    'plots-spectrometry': 'https://groups.google.com/forum/feed/plots-spectrometry/topics/rss.xml?num=15',
    'plots-infrared':     'https://groups.google.com/forum/feed/plots-infrared/topics/rss.xml?num=15',
    'plots-airquality':   'https://groups.google.com/forum/feed/plots-airquality/topics/rss.xml?num=15',
    'plots-waterquality': 'https://groups.google.com/forum/feed/plots-waterquality/topics/rss.xml?num=15',
    'plots-dev':          'https://groups.google.com/forum/feed/plots-dev/topics/rss.xml?num=15'
  };

  var show_list = function (list) {

    $.get(lists[list], function (feed) {
 
      $('.lists').html('');
 
      $.each($(feed).find('channel item').slice(0, 4), function (i, item) { 
 
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
  
        // metaEl.append('by <a class="author"></a>');
        // metaEl.find('.author').attr('href', 'https://publiclab.org/profile/' + author);
        // metaEl.find('.author').append(author);
  
        metaEl.append('<i class="fa fa-envelope-o"></i> ');
        metaEl.append('<span class="date"></span>');
        metaEl.find('.date').append(pubDate);
  
      });

      if (lists[list].match('https://groups.google.com')) {

        $('.lists').append('<a href="https://groups.google.com/forum/#!forum/' + list + '">Read more &raquo;</a>');

      }

    });

  }

  $('a.lists-tab').on('shown.bs.tab', function() { show_list('test'); });

  $('.list-select').change(function() { show_list($(this).val()); });

})();
