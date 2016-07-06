//= require application
//= require jasmine-jquery

var editor;

describe("Plots2", function() {
  var response;

  beforeEach(function() {
    response = null;

    // for phantomjs running
    jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures";

    // for in-browser running... still doesn't work
    //jasmine.getFixtures().fixturesPath = 'assets/fixtures';
    preloadFixtures('index.html');

    jasmine.Ajax.install();

  });

  afterEach(function(){
    jasmine.Ajax.uninstall();
  });

  it("sends a like request when like button is clicked", function() {
    loadFixtures('index.html');
    ajaxSpy = spyOn($, "ajax").and.callFake(function(object) {

      if   (object.url == '/likes/node/1/create') response = "4";
      else response = 'none';

      // check this if you have trouble faking a server response: 
      if (response != 'none'){
        console.log('Faked response to:', object.url)
        console.log(response)
      }
      else console.log('Failed to fake response to:', object.url)
    });

    $('#like-button-1').trigger('click');
    // should trigger the following and our ajaxSpy should return a fake response of "4": 
    // jQuery.getJSON("/likes/node/1/create", function () { ...
    // then triggering like.js code

    expect(response).toEqual('4');

  });
});
