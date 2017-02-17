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

    expect(addHashtags(html)).toEqual('<a href="/tag/timelapse">#timelapse</a> and <a href="/tag/balloon-mapping">#balloon-mapping</a>');

  });

  it("adds deep links like example.com#Sub+section", function() {

    loadFixtures('content.html');
console.log($('#content').html())
console.log($('#content h2').html())
    addDeepLinks($('#content'));
console.log($('#content h2').html())
    expect($('#content h2 i.fa').length).not.toBe(0);

  });

  it("adds table CSS", function() {

    loadFixtures('content.html');
    postProcessContent($('#content'));
    expect($('#content table.table').length).not.toBe(0);

  });

  xit("adds edit links", function() {

    loadFixtures('content.html');

    // insert edit links!!
    processSection(markdown, selector, node_id);

    $('#content .inline-edit-link:first').click()

    expect($('#content form.inline-edit-form:visible').length).toBe(1);

  });

});
