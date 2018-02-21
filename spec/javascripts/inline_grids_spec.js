//= require application
//= require jasmine-jquery
//= require comment_expand

var editor;

describe("Inline grids", function() {

  beforeEach(function() {

    // for phantomjs running
    jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures";

    // for in-browser running... still doesn't work
    //jasmine.getFixtures().fixturesPath = 'assets/fixtures';
//    preloadFixtures('inline_grids.html');

  });


  it("sends a like request when like button is clicked", function() {

    loadFixtures('inline_grid.html');

    expect($($('.notes-grid tr')[1]).find('td:first a').html()).toEqual('First post');

    $('table:first th:first a').trigger('click');

    setTimeout(0, function() {

      expect($($('.notes-grid tr')[1]).find('td:first a').html()).toEqual('Third post');
 
      setTimeout(0, function() {

        $('table:first th:first a').trigger('click');
        expect($($('.notes-grid tr')[1]).find('td:first a').html()).toEqual('First post');

      });

    });

  });

});
