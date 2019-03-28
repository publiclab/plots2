/* eslint-disable no-empty-label */
/* eslint-disable no-unused-expressions */
//= require like

fixture.preload('index.html', 'unlike.html');

describe("Like Button", function () {

  beforeEach(function () {
    fixture.load('index.html', 'unlike.html');
  });

  afterEach(function () {
    ajaxStub.restore();
  });

  it("triggers an ajax request", function() {

    ajaxStub = sinon.stub($, 'ajax', function (object) {
      response = object.url === '/likes/node/1/create' ? '4' : 'none'

      var d = $.Deferred();
      response === '4' ? d.resolve(response) : d.reject(response);
      return d.promise();
      
    });
 
    $("#like-button-1").click();

    expect(ajaxStub).to.have.been.called;
    
  });


  it("it unlikes when already liked", function() {

    ajaxStub = sinon.stub($, 'ajax', function (object) {
      response = object.url === '/likes/node/1/delete' ? '4' : 'none'

      // check this if you have trouble faking a server response:
      // if (response === '4') {
      //   console.log('Faked response to:', object.url)
      // } else {
      //   console.log('Failed to fake response to:', object.url);
      // }

      var d = $.Deferred();
      response === '4' ? d.resolve(response) : d.reject(response);
      return d.promise();

    });

       // should trigger the following and our ajaxSpy should return a fake response of "4":
       // jQuery.getJSON("/likes/node/1/delete").done(function(data){
       //   response = data;
       // })

      $("#like-button-1").click();
      expect($('#like-count-1').html()).to.eql('0');
      
  });

  it("it toggles the like star render", function () {

    ajaxStub = sinon.stub($, 'ajax', function (object) {
      response = object.url === '/likes/node/1/delete' ? '4' : 'none'

      var d = $.Deferred();
      response === '4' ? d.resolve(response) : d.reject(response);
      return d.promise();

    });

    $("#like-button-1").click();
    expect($('#like-star-1')[0].className).to.eql('fa fa-star-o');

  });

});
