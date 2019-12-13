/* eslint-disable no-empty-label */
/* eslint-disable no-unused-expressions */
//= require comment_expand

describe("Comments", function() {

  it("shows expand comment button with remaining comment count", function() {

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
