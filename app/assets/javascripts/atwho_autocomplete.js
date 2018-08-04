    (function() {

      var at_config = {
        at: "@",
        callbacks: {
          remoteFilter: function(query, callback) {
            $.getJSON("/api/srch/profiles?srchString=" + query, {}, function(data) {
              if (data.hasOwnProperty('items') && data.items.length > 0) {
                callback(data.items.map(function(i) { return i.docTitle }));
              }
             });
            }
          },
          limit: 20
        },
        hashtags_config = {
          at: "#",
          callbacks: {
            remoteFilter: function(query, callback) {
              if (query != ''){
                $.post('/tag/suggested/' + query, {}, function(response) {
                   callback(response.map(function(tagnames){ return tagnames }));
                 });
                }
              }
            },
          limit: 20
        },
        emojis_config = {
          at: ':',
          data: Object.keys(emoji).map(function(name){ return {'name': name, 'value': emoji[name]}}),
          displayTpl: "<li>${value} ${name}</li>",
          insertTpl: ":${name}:",
          limit: 100
       }

      $('textarea#text-input').atwho(at_config).atwho(hashtags_config).atwho(emojis_config);
      $('#comment-form').bind('ajax:beforeSend', function(event){
        $("#text-input").prop('disabled',true)
        $("#comment-form .btn-primary").button('loading',true);
      });

      $('#comment-form').bind('ajax:success', function(e, data, status, xhr){
        $('#text-input').prop('disabled',false);
        $('#text-input').val('');
        $('#comments-container').append(xhr.responseText);
        $('#comment-count')[0].innerHTML = parseInt($('#comment-count')[0].innerHTML)+1;
        $("#comment-form .btn-primary").button('reset');
        $('#preview').hide();
        $('#text-input').show();
        $('#preview-btn').button('toggle');
      });

      $('#comment-form').bind('ajax:error', function(e,response){
        notyNotification('mint', 3000, 'success', 'topRight', 'Some error occured while adding comment');
        $('#comment-form .control-group').addClass('has-error')
        $('#comment-form .control-group .help-block ').remove()
        $('#comment-form .control-group').append('<span class="help-block ">Error: there was a problem.</span>')
      });
      })();
