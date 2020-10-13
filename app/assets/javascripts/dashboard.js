$(document).ready(function () {
  $('#selectall').click(function () {
      $('.node-type').prop('checked', this.checked);
  });

  $('.node-type').change(function () {
      var check = ($('.node-type').filter(":checked").length == $('.node-type').length);
      $('#selectall').prop("checked", check);
  });
});
var viewport = function() {
  var e = window, a = 'inner';
  if (!('innerWidth' in window )) {
    a = 'client';
    e = document.documentElement || document.body;
  }
  return { width : e[ a+'Width' ] , height : e[ a+'Height' ] };
}
function listselect(){
  var types = [
    'note',
    'question',
    'event',
    'comment',
    'wiki'
  ];

  
  var selected = [];
  $('#checkboxes input:checked').each(function() {
      selected.push($(this).attr('data-type'));
  });
  let intersection = types.filter(x => selected.includes(x));
  let difference = types.filter(x => !selected.includes(x));
  for(var i=0;i<intersection.length;i++){
    if (!(intersection[i] == 'wiki' && viewport().width > 992)){
    $('.note-container-' + intersection[i]).show();
    }
  }
  for(var j=0;j<difference.length;j++){
    $('.note-container-' + difference[j]).hide();
  }
}

(function() {

  var types = {
    'note':     true, 
    'question': true, 
    'event':    true, 
    'comment':  true, 
    'wiki':     true
  };
 
  


  var setTypeVisibility = function(type, checked) {

    if (type == "all") {

      Object.keys(types).forEach(function(type, i) {

        $('.node-type').prop('checked', checked);
        setTypeVisibility(type, checked);

      });

    } else {


      // record status
      types[type] = (checked == true);


      // record status in browser localStorage
      if (localStorage) {
 
        localStorage.setItem('pl-dash-' + type, checked);
        // match displayed state to localStorage saved state:
        $('.node-type-' + type).prop('checked', checked);
 
      }
   
    $('.node-type').change(function () {
      var check = ($('.node-type').filter(":checked").length == $('.node-type').length);
      $('.node-type-all').prop("checked", check);
    });

    $('.node-type-all').click(function () {
    $('.node-type').prop('checked', this.checked);
    });
      // if all checked?
      var checked_array = $(".node-type").map(function(i, el) { return $(el).prop('checked'); });

      // if contains some falses:
      if (checked_array.toArray().indexOf(false) != -1) {

        // if also contains some trues:
        if (checked_array.toArray().indexOf(true) != -1) {

          $('.node-type-all').prop('indeterminate', true);

        } else {

          $('.node-type-all').prop('checked', false);
          $('.node-type-all').prop('indeterminate', false);

        }

      } else {

        $('.node-type-all').prop('indeterminate', false);
        $('.node-type-all').prop('checked', true);

      }


      // actually hide/show
      if (checked && !(type == 'wiki' && viewport().width > 992)) {
 
        $('.note-container-' + type).show();
 
      } else {
 
        $('.note-container-' + type).hide();
 
      }


      // use CSS clear:left to tidy columns 
      $('.activity .col-md-6').css('clear', 'none');
      $('.activity .col-md-6:visible:even').css('clear', 'left');


      // change dropdown title 
      if ($('.activity-dropdown input.node-type:checked').length < $('.activity-dropdown input.node-type').length) {
 
        $('.activity-dropdown .dropdown-toggle .node-type-filter').html(I18n.t('js.dashboard.selected_updates'));
 
      } else if ($('.activity-dropdown input.node-type:checked').length == 0) {

        $('.activity-dropdown .dropdown-toggle .node-type-filter').html(I18n.t('js.dashboard.none'));

      } else {
 
        $('.activity-dropdown .dropdown-toggle .node-type-filter').html(I18n.t('js.dashboard.all_updates'));
 
      }
 
    }

  }


  // load any settings from browser storage
  var getLocalStorageActivity = function() {  

    if (localStorage) {
 
      Object.keys(types).forEach(function(key, i) {
 
        var type = types[key];
        if (localStorage.getItem('pl-dash-' + key) == null) localStorage.setItem('pl-dash-' + key, true);
        types[key] = localStorage.getItem('pl-dash-' + key) == "true",
        setTypeVisibility(key, types[key]);
 
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

  $('.activity-dropdown li').click(function(e) {

    e.stopPropagation();

    setTypeVisibility($(this).find('input').attr('data-type'), $(this).find('input').prop('checked'));

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

  $('.list-select').change(function(e) { 

    show_list($(this).val());

  });

  $('.search-form-wiki').submit(function(e){ 

    e.preventDefault();
    window.location = '/search/' + $('.search-form-wiki input').val();

  })

})();
