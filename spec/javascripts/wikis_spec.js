//= require application
//= require jasmine-jquery
//= require wikis

var editor;

describe("Wikis", function() {

  beforeEach(function() {

    // for phantomjs running
    jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures";

    // for in-browser running... still doesn't work
    //jasmine.getFixtures().fixturesPath = 'assets/fixtures';
    preloadFixtures('content.html');

    jasmine.Ajax.install();

  });


  afterEach(function(){

    jasmine.Ajax.uninstall();

  });

  it("adds deep links like example.com#Sub+section", function() {

    loadFixtures('content.html');
    addDeepLinks($('#content'));
    expect($('#content h2 i.fa').length).not.toBe(0);

  });

  it("adds table CSS", function() {

    loadFixtures('content.html');
    postProcessContent($('#content'));
    expect($('#content table.table').length).not.toBe(0);

  });

});
