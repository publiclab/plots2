$(document).ready(function() 
{
      $('#taginput').typeahead({
        items: 8,
        minLength: 3,
        source: function (query, process) {
          var replaced_query = query.replace(' ', /-/g);
          return $.post('/tag/suggested/' + replaced_query, {}, function (data) {
            return process(data)
          })
        },
        updater: function(text) {
          $('#taginput').val(text)
          window.location = "/tag/" + text;
        }
      });

      $('#tagform').submit(function(e) {
        e.preventDefault();
        window.location = "/tag/" + ($('#taginput').val()).replace(/\s/g, '-');
      });
      $('.index-follow-buttons').on('ajax:success', function(data, status, xhr){
	    console.log("Hello");
	    var data_recv = JSON.parse(JSON.stringify(status));
	    notyNotification('relax', 3000, 'success', 'top', data_recv.message + 'Click <a href="../subscriptions"> here </a> to manage your subscriptions. ');
	    var html_new = '<a rel="tooltip" title=Following class="btn btn-default btn-sm active" href="/unsubscribe/tag/'+ data_recv.tagname + '"> <i class="fa fa-user-plus" aria-hidden="true"></i>Following</a>';
	    $('#follow-unfollow-column-'+data_recv.id).html(html_new); 
	  });
      $('.index-follow-buttons').on('ajax:error', function(data, status, xhr){
        var data_recv = JSON.parse(JSON.stringify(status));
        notyNotification('relax', 3000, 'error', 'top', data_recv.message + 'Click <a href="../subscriptions"> here </a> to manage your subscriptions. ');
      });
});

