//= require application
//= require question

var editor;

describe("Question", function() {

  beforeEach(function() {

    // for phantomjs running
    jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures";

    // for in-browser running... still doesn't work
    //jasmine.getFixtures().fixturesPath = 'assets/fixtures';
    preloadFixtures('content.html');

  });

  it("loads question.js", function() {

    //loadFixtures('content.html');
    expect(true).toBe(true); // just confirm that things were loaded at all

  });

});
