(function() {

  $('a.lists-tab').on('shown.bs.tab', function (e) {

    $.get('http://rssmixer.com/feed/2851.xml', function (feed) {
    //$.get('http://feeds.feedburner.com/rssmixer/ZvcX', function (feed) {
 
      $('.lists i').remove();
 
      $.each($(feed).find('channel item').slice(0, 4), function (i, item) { 
  
        $('.lists').append('<div class="feed-item-' + i + '"></div>');
  
        var itemEl       = $('.lists .feed-item-' + i),
            title        = $(item).find('title').html(),
            link         = $(item).find('link').html(),
            author       = $(item).find('author').html(),
            pubDate      = $(item).find('pubDate').html(),
            description  = $(item).find('description').html();
  
        pubDate = moment(new Date(pubDate)).format("MMM Do");
  
        itemEl.append('<h4 class="title"></h4>');
        itemEl.find('.title').append('<a></a>');
        itemEl.find('.title a').attr('href', link);
        itemEl.find('.title a').append(title);
  
        var metaEl = itemEl.append('<p class="meta"></p>');
  
        // metaEl.append('by <a class="author"></a>');
        // metaEl.find('.author').attr('href', 'https://publiclab.org/profile/' + author);
        // metaEl.find('.author').append(author);
  
        metaEl.append('<span class="date"></span>');
        metaEl.find('.date').append(pubDate);
  
      });

    });
console.log('sent req'); 

  });

})();
