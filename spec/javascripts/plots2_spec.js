//= require jquery
//= require jasmine-jquery

var editor;

describe("Plots2", function() {

  beforeAll(function() {

    // for phantomjs running
    jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures";

    // for in-browser running... still doesn't work
    //jasmine.getFixtures().fixturesPath = 'assets/fixtures';

    fixture = loadFixtures('index.html');

    jasmine.Ajax.install();

    ajaxSpy = spyOn($, "ajax").and.callFake(function(object) {

      var response;
      if   (object.url == '/likes/node/1/create') response = "4";
      else response = 'none';

      // check this if you have trouble faking a server response: 
      if (response != 'none') console.log('Faked response to:', object.url)
      else console.log('Failed to fake response to:', object.url)

    });

  });


  xit("sends a like request when like button is clicked", function() {

    $('.btn-like').trigger('click');
    // should trigger the following and our ajaxSpy should return a fake response of "4": 
    // jQuery.getJSON("/likes/node/1/create", function () { ...
    // then triggering like.js code

    expect($('#like-count-1').html()).toEqual('4');

  });


});
