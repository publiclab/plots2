/*
 Table generation:

| col1 | col2 | col3 |
|------|------|------|
| cell | cell | cell |
| cell | cell | cell |
*/

module.exports = function initTables(_module, wysiwyg) {

  function createTable(cols, rows) {

    cols = cols || 3;
    rows = rows || 2;

    var table = "|";

    for (var col = 0; col < cols; col++) {

      table = table + " col" + col + " |";

    }

    table = table + "\n|";

    for (var col = 0; col < cols; col++) {

      table = table + "------|";

    }

    table = table + "\n";

    for (var row = 0; row < rows; row++) {

      table = table + "|";

      for (var col = 0; col < cols; col++) {
     
        table = table + " cell |";
     
      }

      table = table + "\n";

    }

    return table + "\n";

  }


  // create a submenu for sizing tables
  $('.wk-commands').append('<a class="woofmark-command-table btn btn-default"><i class="fa fa-table"></i></a>');

  var builder  = '<div class="form-inline form-group ple-table-popover" style="width:400px;">';
      builder += '<input value="4" class="form-control rows" style="width:75px;" />';
      builder += ' x ';
      builder += '<input value="3" class="form-control cols" style="width:85px;" /> ';
      builder += '<a class="ple-table-size btn btn-default"><i class="fa fa-plus"></i></a>';
      builder += '</div>';

  $('.woofmark-command-table').attr('data-content', builder);
  $('.woofmark-command-table').attr('data-container', 'body');
  $('.woofmark-command-table').attr('data-placement','top');

  $('.woofmark-command-table').popover({ html : true });

  $('.wk-commands .woofmark-command-table').click(function() {

    $('.ple-table-size').click(function() {

      wysiwyg.runCommand(function(chunks, mode) {

        var table = createTable(
          +$('.ple-table-popover .cols').val(),
          +$('.ple-table-popover .rows').val()
        );

        if (mode === 'markdown') chunks.before += table;
        else {

          chunks.before += _module.wysiwyg.parseMarkdown(table);
          setTimeout(_module.afterParse, 0); // do this asynchronously so it applies Boostrap table styling

        }

        $('.woofmark-command-table').popover('toggle');

      });

    });

  });

}
