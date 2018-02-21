var Profile = {
  value: { 
    user_id: null,
    name: null,
    
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
		data = {
		labels: ["12am-3am", "3am-6am", "6am-9am", "9am-12pm",
		  "12pm-3pm", "3pm-6pm", "6pm-9pm", "9pm-12am"],

		datasets: [
		  {
			title: "Some Data",
			values: [25, 40, 30, 35, 8, 52, 17, -4]
		  },
		  {
			title: "Another Set",
			values: [25, 50, -10, 15, 18, 32, 27, 14]
		  },
		  {
			title: "Yet Another",
			values: [15, 20, -3, -15, 58, 12, -17, 37]
		  }
		]
	  };

	  chart = new Chart({
		parent: "#note-graph", // or a DOM element
		title: "My Awesome Chart",
		data: data,
		type: 'bar', // or 'line', 'scatter', 'pie', 'percentage'
		height: 250,

		colors: ['#7cd6fd', 'violet', 'blue'],
		// hex-codes or these preset colors;
		// defaults (in order):
		// ['light-blue', 'blue', 'violet', 'red',
		// 'orange', 'yellow', 'green', 'light-green',
		// 'purple', 'magenta', 'grey', 'dark-grey']

		format_tooltip_x: d => (d + '').toUpperCase(),
		format_tooltip_y: d => d + ' pts'
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
