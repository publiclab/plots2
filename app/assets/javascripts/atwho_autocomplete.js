(function() {

  var at_config = {
    at: "@",
    callbacks: {
      remoteFilter: function(query, callback) {
        $.getJSON("/api/srch/profiles?query=" + query + "&sort_by=recent&field=username", {}, function(data) {
          if (data.hasOwnProperty('items') && data.items.length > 0) {
            callback(data.items.map(function(i) { return i.doc_title }));
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
  })();
