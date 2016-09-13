//= require application
//= require jasmine-jquery
//= require tagging

var editor;

describe("Tagging", function() {

  beforeAll(function() {

    // for phantomjs running
    jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures";

    loadFixtures('tagging.html');

    initTagForm(2);

  });


  // this should test addTag(tagname, selector) from tagging.js, which is an ajax request
  xit("tests tag deletion", function() {

    $('tags.label:first a.tag-delete').trigger('click');

    setTimeout(0, function() {

      // expect tag to be greyed out
      expect($('tags.label:first a.tag-delete').css('opacity')).toBe(0.5);

    });
    

  });


  // this should test addTag(tagname, selector) from tagging.js, which is an ajax request
  xit("adds a tag", function(done) {

    addTag('boss');

    el.bind('ajax:success', function(e, response){

    // drop the test expectations to the bottom of the task queue
    setTimeout(0, function() {

      // assert tag properly constructed here
      // expect($('#tag_...).toBe(true);

      done();

    });

  });

});
