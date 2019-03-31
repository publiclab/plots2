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
        url : `/profile/comments/${Profile.value.user_id}`,
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
    let heatmap = new Chart({
    parent: "#note-graph",
    type: 'heatmap',
    height: 115,
    data: this.value.notes
  	}); 
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

class Reset {
    validateEmail(sEmail){
        const filter = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return filter.test(sEmail); 
    }

    runValidation(event){ 
        const email = $('#validEmail').val();

        if(!this.validateEmail(email)) {
            $("#validPrint").attr("style", "display:block");
            $("#validPrint").html("<p>Invalid email address</p>");
            event.preventDefault();
        }
    }
}
