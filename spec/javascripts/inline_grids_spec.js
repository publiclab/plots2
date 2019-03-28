/* eslint-disable no-empty-label */

var editor;

fixture.preload("inline_grid.html");

describe("Inline grids", function() {

  beforeEach(function() {

      this.fixtures = fixture.load("inline_grid.html");

  });


  it("sends a like request when like button is clicked", function() {


    expect($($('.notes-grid tr')[1]).find('td:first a').html()).to.eql('First post');

    $('table:first th:first a').trigger('click');

    setTimeout(0, function() {

      expect($($('.notes-grid tr')[1]).find('td:first a').html()).to.eql('Third post');
 
      setTimeout(0, function() {

        $('table:first th:first a').trigger('click');
        expect($($('.notes-grid tr')[1]).find('td:first a').html()).to.eql('First post');

      });

    });

  });

});
