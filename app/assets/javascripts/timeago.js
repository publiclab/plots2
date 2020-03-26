// Function by caiotarifa: https://gist.github.com/caiotarifa/30ae974f2293c761f3139dd194abd9e5
//
// using this function instead of distance_of_time_in_words in Ruby for the map popups calculation in leaflet_helper.js

var TimeAgo = (function() {
    var self = {};
    
    // Public Methods
    self.locales = {
      prefix: '',
      sufix:  'ago',
      
      seconds: '1 minute',
      minute:  '1 minute',
      minutes: '%d minutes',
      hour:    '1 hour',
      hours:   '%d hours',
      day:     '1 day',
      days:    '%d days',
      month:   '1 month',
      months:  '%d months',
      year:    '1 year',
      years:   '%d years'
    };
    
    self.inWords = function(timeAgo) {

      var seconds = Math.floor((new Date() - new Date(timeAgo)) / 1000),
          separator = this.locales.separator || ' ',
          words = this.locales.prefix + separator,
          interval = 0,
          intervals = {
            year:   seconds / 31536000,
            month:  seconds / 2592000,
            day:    seconds / 86400,
            hour:   seconds / 3600,
            minute: seconds / 60
          };
      
      var distance = this.locales.seconds;
      
      for (var key in intervals) {
        if (intervals.hasOwnProperty(key)) {
          interval = Math.floor(intervals[key]);
          
          if (interval > 1) {
            distance = this.locales[key + 's'];
            break;
          } else if (interval === 1) {
            distance = this.locales[key];
            break;
          }
        }
      }
      
      distance = distance.replace(/%d/i, interval);
      words += distance + separator + this.locales.sufix;
  
      return words.trim();
    };
    
    return self;
  }());