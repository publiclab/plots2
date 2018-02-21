//= require application
//= require jasmine-jquery
//= require comment_expand

var editor;

describe("Plots2", function() {

  beforeEach(function() {

    // for phantomjs running
    jasmine.getFixtures().fixturesPath="../../spec/javascripts/fixtures";

    // for in-browser running... still doesn't work
    //jasmine.getFixtures().fixturesPath = 'assets/fixtures';
    preloadFixtures('index.html', 'unlike.html', 'comment_expand.html');

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
        console.log('Faked response to:', object.url);
        console.log(response);
      }
      else console.log('Failed to fake response to:', object.url);

      // http://stackoverflow.com/questions/13148356/how-to-properly-unit-test-jquerys-ajax-promises-using-jasmine-and-or-sinon
      var d = $.Deferred();
      d.resolve(response);
      d.reject(response);
      return d.promise();

    });

    $('#like-button-1').trigger('click');

    // should trigger the following and our ajaxSpy should return a fake response of "4":
    // jQuery.getJSON("/likes/node/1/create", {}, function() { ...
    // then triggering like.js code

    expect(response).toEqual('4');
    expect($('#like-count-1').html()).toEqual('4'); // passing
    expect($('#like-star-1')[0].className).toEqual('fa fa-star');

  });


  it("unlikes a request if already liked", function() {

    loadFixtures('unlike.html');

    ajaxSpy = spyOn($, "ajax").and.callFake(function(object) {

      if   (object.url == '/likes/node/1/delete') response = "-1";
      else response = 'none';

      var d = $.Deferred();
      d.resolve(response);
      d.reject(response);
      return d.promise();

    });

    $('#like-button-1').trigger('click');

    expect(response).toEqual('-1');
    expect($('#like-count-1').html()).toEqual('0');
    expect($('#like-star-1')[0].className).toEqual('fa fa-star-o');

  });

  it("shows expand comment button with remaining comment count", function(){
    loadFixtures('comment_expand.html');

    $('#answer-0-expand').trigger('click');
    expect($('#answer-0-expand').html()).toEqual('View 2 previous comments');

    $('#answer-0-expand').trigger('click');
    expect($('#answer-0-expand').css('display')).toEqual('none');
  });

  it("loads up i18n-js library properly", function() {
    expect(I18n.t('js.dashboard.selected_updates')).toBe('Selected updates')
  });

});
