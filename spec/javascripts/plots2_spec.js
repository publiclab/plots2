var editor;

describe("Plots2", function() {

  beforeEach(function() {

    fixture.preload('index.html', 'unlike.html', 'comment_expand.html');

  });

  it("sends a like request when like button is clicked", function() {

    fixture.load('index.html');

    ajaxStub = sinon.stub($, 'ajax', function(object) {

		var response;
		if   (object.url == '/likes/node/1/create') response = '4';
		else response = 'none';

		// check this if you have trouble faking a server response:
		if (response == '4'){
            console.log('Faked response to:', object.url);
		}
		else console.log('Failed to fake response to:', object.url);

		var d = $.Deferred();
        if(response == '4')
		    d.resolve(response);
        else
		    d.reject(response);
		return d.promise();

	});

    $('#like-button-1').trigger('click');

    // should trigger the following and our ajaxSpy should return a fake response of "4":
    response = jQuery.getJSON("/likes/node/1/create", {}, function() {});
    // then triggering like.js code

    //expect(response).toEqual('4');
    //expect($('#like-count-1').html()).to.eql('4'); // passing
    //expect($('#like-star-1')[0].className).to.eql('fa fa-star');

  });


  xit("unlikes a request if already liked", function() {

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

  xit("shows expand comment button with remaining comment count", function(){
    loadFixtures('comment_expand.html');

    $('#answer-0-expand').trigger('click');
    expect($('#answer-0-expand').html()).toEqual('View 2 previous comments');

    $('#answer-0-expand').trigger('click');
    expect($('#answer-0-expand').css('display')).toEqual('none');
  });

  xit("loads up i18n-js library properly", function() {
    expect(I18n.t('js.dashboard.selected_updates')).toBe('Selected updates')
  });

});
