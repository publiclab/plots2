/*
 * History of edits, sorted by day. 
 */

var Class  = require('resig-class'),
    moment = require('moment');

module.exports = PublicLab.History = Class.extend({

  init: function(_editor, options) {

    var _history = this;

    if (options === true) options = {};
    _history.options = options || {};

    // this would be the nid in Drupal
    // plus the username, or just a
    // unique id if it's a new post
    _history.options.id       = _history.options.id || 0;// (new Date()).getTime();
    _history.options.interval = _history.options.interval || 10000; // ten second default
    _history.options.prefix   = _history.options.prefix || "publiclab-editor-history-";
    _history.options.element  = _history.options.element || $('.ple-history')[0]; // element in which to display/update saved states

    // unique key to fetch storage
    _history.key = _history.options.prefix + _history.options.id; 


    if (window.hasOwnProperty('localStorage')) {


      // Fetch the entire history of this post from localStorage
      _history.fetch = function() {

        _history.log = JSON.parse(localStorage.getItem(_history.key)) || [];

        if (_history.options.debug) console.log('history: fetched', _history.log.length);

        return _history.log;

      }


      // Empties history permanently, including
      // localstorage, so be careful
      _history.flush = function() {

        if (_history.options.debug) console.log('history: flushing');
        _history.log = [];

        localStorage.setItem(_history.key, false);

      }


      // Write the entire history of this post to localStorage;
      // overwrites previous history, so be careful
      _history.write = function() {

        // maintain history length at 20 items
        if (_history.log.length > 20) _history.log.shift();

        if (_history.options.debug) console.log('history: overwriting');
        var string = JSON.stringify(_history.log)

        // minimal validation:
        if (_history.log instanceof Array  
            && typeof string    == 'string' 
            && string[0]        == '[') {

          localStorage.setItem(_history.key, string);

        }

      }


      // Add an item to the history (history.log)
      // and write to localStorage.
      _history.add = function(text) {

        $('.ple-history-saving').fadeIn();
        setTimeout(function() {
          $('.ple-history-saving').fadeOut();
        }, 500);

        var entry = {

          text:      text,
          timestamp: (new Date()).getTime()
          // type: 'minor'

        }

        _history.log.push(entry);
        _history.write();

      }


      // Add an item ONLY if it's different from the last entry
      _history.addIfDifferent = function(text) {

        if (_history.last() && text != _history.last().text) {

          _history.add(text);
          if (_history.options.debug) console.log('history: entry saved');

          return true;

        } else if (_history.last()) {

          _history.last().timestamp = (new Date()).getTime()
          //if (_history.options.debug) console.log('history: last entry timestamp updated', _history.last());

          return false;

        } else {

          _history.add(text);
          if (_history.options.debug) console.log('history: first entry saved');

          return true;

        }

      }


      // Most recent history entry
      _history.last = function() {

        if (_history.log.length > 0 ) {

          return _history.log[_history.log.length - 1];

        } else {

          return null;

        }

      }


      // Actually get the contents of the passed textarea and store
      _history.check = function() {

        var changed = _history.addIfDifferent(_editor.richTextModule.value());
        var element = _history.options.element;

        // only if it's changed, or if it hasn't yet been created
        if (element && ($(element).find('*').length === 0 || changed)) _history.display(element);

      }


      // Inserts recent history into given DOM
      // element, after emptying it.
      _history.display = function(element) {

        element = element || _history.options.element;

        $(element).html(''); // empty it

        // SELECT element mode is not yet used
        if (element.nodeName == 'SELECT') {

          _history.log.forEach(function(log, i) {

            var time = moment(new Date(log.timestamp)).fromNow();
            $(element).append('<option value="' + log.timestamp + '">' + time + '</option>');

          });

        } else if (element.nodeName == 'DIV') {

          var dateClasses = [];

          _history.log.forEach(function(log, i) {

            log.formattedDate = log.formattedDate || moment(new Date(log.timestamp)).format("MMM Do YYYY"); // Aug 2nd 2016
            log.dateClass = log.dateClass || log.formattedDate.replace(/ /g, '-');

            var time      = moment(new Date(log.timestamp)).fromNow(),
                className = 'ple-history-' + log.timestamp,
                html = '';

            // before a day's log entries:
            if (i === 0 || (i > 0 && log.formattedDate != _history.log[i - 1].formattedDate)) {

              
              dateClasses.push(log.dateClass);
              html += '<p class="day day-' + log.dateClass + '"><em>' + log.formattedDate + '</em> | <a class="count"></a> | <a class="clear">clear</a></p>';

            }

            html += '<p style="display:none;" class="log day-' + log.dateClass + ' ' + className + '">';
            html += '<b>' + i + '</b>: ';
            html += '<a class="btn btn-xs btn-default revert">revert</a> <a class="btn btn-xs btn-default clear">clear</a> | Preview: ';
            html += time;
            html += ' -- <i class="preview">' + log.text.substr(0, 30) + '...</i>';
            html += '</p>';

            $(element).append(html);

            $(element).find('.' + className + ' a.revert').click(function(e) {

              _editor.richTextModule.value(log.text);
              $('.ple-menu-more').hide();
              setTimeout(_editor.richTextModule.afterParse, 0);

            });

            $(element).find('.' + className + ' a.clear').click(function(e) {

              _editor.history.log.splice(_editor.history.log.indexOf(log), 1);
              $(element).find('.' + className).remove();

            });

          });

          // now go through by day
          dateClasses.forEach(function countDateClasses(dateClass, i) {

            // count how many of each there are
            $('.day.day-' + dateClass).find('.count').html($('.log.day-' + dateClass).length + ' entries')

            $('.day.day-' + dateClass + ' .count').click(function showDay() {

              $('.log.day-' + dateClass).toggle();

            });

            // clear these log entries
            $('.day.day-' + dateClass + ' .clear').click(function clearDay() {

              if (confirm('Are you sure? There is no undo.')) {
                // in both history module and DOM elements
                $('.log.day-' + dateClass + ' .clear').trigger('click');
                // refresh
                _editor.history.display(element);
              }

            });

          });

          // open last day by default
          $('.day:last .count').trigger('click');

          $(element).height(parseInt($(window).height() * 0.5));

        }

      }


      _history.fetch();

      setInterval(_history.check, _history.options.interval);

      $(_editor.richTextModule.options.textarea).on('change', function() {

        _history.check();

      });

      _history.check();


    } else {

      console.log('history requires localStorage-enabled browser');

    }

  }

});
