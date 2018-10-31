//= require comment_expand
var editor;

describe("Plots2", function() {
  it("sends a like request when like button is clicked", function() {
    fixture.load('like.html');
    ajaxStub = sinon.stub($, 'ajax', function(object) {
      if (object.url == '/likes/node/1/create') response = '1';
      else response = 'none';

      var d = $.Deferred();
      if (response == '1'){
		    d.resolve(response);
      } else {
		    d.reject(response);
      }
      return d.promise();
    });

    // Initially it's not liked
    setLikeState(false);
    $("#like-button-1").on('click', toggleLike);

    $(document).ready(function(){
      $("#like-button-1").click();
      expect($('#like-count-1').html()).to.eql('1');
      expect($('#like-star-1')[0].className).to.eql('fa fa-star');
      ajaxStub.restore();
    });
  });

  it("unlikes a request if already liked", function() {
    fixture.load('unlike.html');
    ajaxStub = sinon.stub($, 'ajax', function(object) {
      if (object.url == '/likes/node/1/delete') response = '-1';
      else response = 'none';

      var d = $.Deferred();
        if (response == '-1'){
          d.resolve(response);
        } else {
          d.reject(response);
        }
        return d.promise();
    });

    // Initially it's liked
    setLikeState(true);
    $("#like-button-1").on('click', toggleLike);

    $(document).ready(function(){
      $("#like-button-1").trigger('click');
      expect($('#like-count-1').html()).to.eql('0');
      expect($('#like-star-1')[0].className).to.eql('fa fa-star-o');
      ajaxStub.restore();
    });
  });

  it("shows expand comment button with remaining comment count", function(){
    fixture.load('comment_expand.html');

    expand_comments(0);
    expect($('#answer-0-expand').html()).to.eql('View 2 previous comments');

    expand_comments(0);
    expect($('#answer-0-expand').css('display')).to.eql('none');
  });

  it("loads up i18n-js library properly", function() {
    expect(I18n.t('js.dashboard.selected_updates')).to.eql('Selected updates')
  });
});
