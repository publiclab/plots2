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
      if   (object.url == '/likes/node/1/delete') response = "4";
      else response = 'none';

      // check this if you have trouble faking a server response: 
      if (response != 'none') console.log('Faked response to:', object.url)
      else console.log('Failed to fake response to:', object.url)

    });

  });


  it("sends a like request when like button is clicked", function() {

    $('.btn-like').trigger('click');
    // should trigger: 
    // jQuery.getJSON("/likes/node/"+node_id+"/create", function () {
    // but depends on a unique id which isn't in our fixture:
    // $('#like-button-'+node_id).on('click',clicknotliked);

    expect($('#like-count-1').html()).toEqual('4');

  });


});
