//= require application
//= require jasmine-jquery
//= require comment_expand

var editor;

describe("Wikis", function() {

  beforeEach(function() {

    // for phantomjs running
    jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures";

    jasmine.Ajax.install();

  });


  afterEach(function(){

    jasmine.Ajax.uninstall();

  });


  it("adds callout links", function() {

    //loadFixtures('index.html');

    var html = "@warren";

    expect(addCallouts(html)).toEqual('<a href="/profile/warren">@warren</a>');

    html = "@warren and @liz";

    expect(addCallouts(html)).toEqual('<a href="/profile/warren">@warren</a> and <a href="/profile/liz">@liz</a>');

  });

  it("adds hashtag links", function() {

    //loadFixtures('index.html');

    var html = "#timelapse and #balloon-mapping";

    expect(addCallouts(html)).toEqual('<a href="/tag/timelapse">@timelapse</a> and <a href="/tag/balloon-mapping">@balloon-mapping</a>');

  });

});
