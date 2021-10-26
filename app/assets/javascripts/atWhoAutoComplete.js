(function() {

  // settings at https://github.com/ichord/At.js/wiki/Base-Document#settings

  let userObj = null;

  // stores recently active users in userObj
  (function storeRecentlyActiveUsers() {
    fetch('/users/active').then(res => res.json()).then(data => { userObj = data })
  })();

  // checks if the 'name' key in the JSON data is named 'username' or 'name' and then returns the
  // correct key-value
  const displayName = (item) => item.username ? item.username : item.name;

  // displays a recently active text for prioritised users
  const displayPriorityUsers = item => {
    const username = displayName(item);
    if(item.priority) {
      return username + ' <small>recently active</small>'
    }
    return username
  }

  // returns a list of users that match the query
  const filterUsers = query => {
    const users = []
    userObj.forEach(str => {
      if(str.username.includes(query)){
        users.push(str.username)
      }
    });

    return users
  };

  // remove duplicates of prioritised usernames
  const removeDuplicates = (userArr, prioritisedUsers) => {
    const newData = []
    userArr.forEach(i => {
      if(!prioritisedUsers.includes(i.doc_title)){
        newData.push({name: i.doc_title, priority: false})
      }
    });

    return newData;
  }

  // merges normal and prioritised usernames
  const mergeUsers = (recentlyActiveUsers, normalUsers) => {
    const prioritisedUsers = recentlyActiveUsers.map(user => { 
      return { name: user, priority: true }
    })

    return prioritisedUsers.concat(normalUsers);
  }

  var at_config = {
    at: "@",
    displayTpl: (item) => `<li>${displayPriorityUsers(item)}</li>`,
    insertTpl: (item) => `@${displayName(item)}`,
    // loads and saves remote JSON data by URL
    data: '/users/active',
    delay: 400,
    callbacks: {
      remoteFilter: debounce(function(query, callback) {
        $.getJSON("/api/srch/profiles?query=" + query + "&sort_by=recent&field=username", {}, function(data) {
          if (data.hasOwnProperty('items') && data.items.length > 0) {
            const prioritisedUsers = filterUsers(query);
            const normalUsers = removeDuplicates(data.items, prioritisedUsers);
            const mergedUsers = mergeUsers(prioritisedUsers, normalUsers);
            callback(mergedUsers);
          }
         });
        }, 200)
      },
      limit: 20
    },
    hashtags_config = {
      at: "#",
      delay: 400,
      callbacks: {
        remoteFilter: debounce(function(query, callback) {
          if (query != ''){
            $.post('/tag/suggested/' + query, {}, function(response) {
               callback(response.map(function(tagnames){ return tagnames }));
             });
            }
          }, 200)
        },
      limit: 20
    },
    emojis_config = {
      at: ':',
      delay: 400,
      data: Object.keys(emoji).map(function(name){ return {'name': name, 'value': emoji[name]}}),
      displayTpl: "<li>${value} ${name}</li>",
      insertTpl: ":${name}:",
      limit: 100
   }

  $('textarea.text-input')
    .atwho(at_config)
    .atwho(hashtags_config)
    .atwho(emojis_config);

})();
