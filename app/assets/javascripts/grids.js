function setupGridSorters(selector) {
  $(selector).find('th a').click(function(a) {
    sortGrid($(a.target).attr('data-type'), selector, a.target);
  });
}

function sortGrid(type, selector, headerLink) {

  var table = $(selector),
      headerLink = $(headerLink),
      desc = headerLink.hasClass('desc'),
      header = table.find('tr:first').detach(),
      rows = table.find('tr').detach();

  rows = rows.sort(function(a, b){

    var cellA = $(a).find('.' + type);
    var cellB = $(b).find('.' + type);

    // look for data-timestamp, also insert it in application_helper.rb

    if (cellA.attr('data-timestamp')) {

      if (desc) return cellA.attr('data-timestamp') > cellB.attr('data-timestamp');
      else      return cellA.attr('data-timestamp') < cellB.attr('data-timestamp');
      
    } else {

      if (desc) return cellA.text() > cellB.text();
      else      return cellA.text() < cellB.text();

    }

  });

  table.append(header);
  table.append(rows);

  headerLink.toggleClass('desc');

}
