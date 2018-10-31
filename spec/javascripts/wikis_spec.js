//= require application
//= require wikis

var editor;

describe("Wikis", function () {
  beforeEach(function () {
    fixture.preload('content.html');
  });

  it("adds deep links like example.com#Sub+section", function () {
    fixture.load('content.html');
    addDeepLinks($('#content'));
    expect($('#content h2 i.fa').length).to.not.equal(0);
  });

  it("adds table CSS", function () {
    fixture.load('content.html');
    postProcessContent($('#content'));
    expect($('#content table.table').length).to.not.equal(0);
  });
});
