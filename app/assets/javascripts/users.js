var Profile = {
  value: { 
    user_id: null,
    name: null,
    notes: null,
    comments: null
  },
  display_comments: function(){
    $('a#comments-tab').on('shown.bs.tab',function (e) {
      $.ajax({
        url : '/profile/comments/' + Profile.value.user_id,
        type: 'GET',
        success: function(response){
          $('#comments').html(response);
        }
      });
    });
    $('#questions .btn-group .btn').click(function(){
      $(this).addClass('active').siblings().removeClass('active');
    });
  },
  plot_graph: function(){
    flotoptions_minimal = {
      yaxis: { show: false },
      xaxis: { show: true },
      grid: {
        borderWidth: 0,
        //color: "#444",
        markers: []
      },
      colors: [ "#08f", "#80f" ]
    }

    $.plot($("#note-graph"), [
      {
        data: Profile.value.notes,
        hoverable: true,
//      label: "Research Notes",
        bars: { show: true, 
                lineWidth: 0,
                fillColor: "#08f",
                barWidth: 0.5
              }
      }//,
//    {
//      data: value.comments,
//      hoverable: true,
//      label: "Comments",
//      bars: { show: true, 
//              lineWidth: 0,
//              fillColor: "#80f",
//              barWidth: 0.5
//            }
//    }
    ],flotoptions_minimal);
  },
  fetch_maps: function(){
    $.get('https://mapknitter.org/feeds/author/' + Profile.value.name, function (feed) {

      if ($(feed).find('channel item').length > 0){
        $('.nav-tabs').append('<li><a href="#maps" data-toggle="tab"><i class="fa fa-map-marker"></i><span class="hidden-sm hidden-xs"> MapKnitter maps</span></a></li>');
      }
      
      $.each($(feed).find('channel item'), function (i, item) { 

        $('#maps table').append('<tr class="feed-item-' + i + '"></tr>');
        
        var itemEl       = $('#maps table .feed-item-' + i),
            title        = $(item).find('title').html(),
            link         = $(item).find('link').html(),
            author       = $(item).find('author').html(),
            pubDate      = $(item).find('pubDate').html(),
            id           = $(item).find('guid').html().split('maps/')[1],
            description  = $(item).find('description').text(),
            image        = $(item).find('image').html();
            pubDate      = moment(new Date(pubDate)).fromNow();
        
        itemEl.append('<td class = "title"><a><i class="fa fa-map-marker"></i></a></td>');
        itemEl.find('a').attr('href', link);
        itemEl.find('.title a').append(' ' + title);

        itemEl.append('<td class="date"></td>');
        itemEl.find('.date').append(pubDate);

        itemEl.append('<td class="image"><img src=""></td>');
        itemEl.find('.image img').attr('src', image);

      });
    });
  }
}
