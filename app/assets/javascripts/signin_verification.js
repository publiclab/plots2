var publicSpamCompleted = false;
var publicHasSubmitted = false;
var publicUsingSpamaway = ($('.spamaway').length > 0);

function recaptchaSuccess() {
  publicSpamCompleted = true;
  console.log('Test: ReCaptcha submitted successfully');
  publicSpamCompletedChange();
}

function recaptchaExpired() {
  publicSpamCompleted = false;
  console.log('Test: ReCaptcha expired.');
}

$(document).ready(function() {
  if (publicUsingSpamaway) {
    $('.spamaway button').each(function() {
      $(this).find('input').prop('checked', false);
    });
  } else {
    $('.g-recaptcha').attr({
      'data-callback': 'recaptchaSuccess',
      'data-expired-callback': 'recaptchaExpired'
    });
  }
});

function publicSpamCompletedChange(scroll) {
  var spamElement = (publicUsingSpamaway) ? $('.spamaway') : $('.g-recaptcha').find('iframe');
  if (!publicSpamCompleted) {
    spamElement.css({
      'border': '2px solid red',
      'padding': '1px',
      'borderRadius': '5px'
    });
  } else {
    spamElement.css({
      'border': '',
      'padding': '',
      'borderRadius': ''
    });
  }
  if(scroll) {
    var offset = spamElement.offset().top
    $('html, body').animate({
      scrollTop: offset - $(window).height() / 2
    });
  }
}

if (publicUsingSpamaway) {
  $('.spamaway button').click(function(e) {
    $(this).find('input').prop('checked', true);
  });
  //Check spamaway completion
  var btnClicked = new Array(4).fill(false);
  var btnArray = $('.spamaway .btn-group-justified');
  $('.spamaway').on('click', '.btn-group-justified', function(e) {
    var i = btnArray.index($(this));
    if (!btnClicked[i]) {
      btnClicked[i] = true;
      publicSpamCompleted = btnClicked.every(function(clicked) {
        return clicked === true
      });
    }
    if (publicHasSubmitted) {
      publicSpamCompletedChange();
    }
  });
}

(function() {
  $('.btn-save').click(function onClick(e) {
    $('.form-control').trigger('keyup'); //Prevents bypassing check when all fields have not been touched
    var validated = checkValidation(publicHasSubmitted);
    if (publicSpamCompleted && validated || publicHasSubmitted) {
      $(this).addClass("disabled") // disable the button after it is clicked
        .html("<i class='fa fa-spinner fa-spin'></i>"); // make a spinner that spins when clicked
    } else {
      publicHasSubmitted = true;  
      e.preventDefault();
      publicSpamCompletedChange(validated);
      $('#password-confirmation').trigger('keyup'); //Now that it has been submitted once these fields can highlight on 0 chars
    }

      
      
  });

  //Check that all are valid
  function checkValidation(hasSubmitted) {
    if(hasSubmitted) return;
    var validated = true;
    $('.validate').each(function() {
      var valid = $(this).html() === '' && !($(this).prop('id') === "password-match") || $(this).hasClass('chk');
      if (!valid) { //Check that all messages are clear
        validated = false;
        var self = this;
        var offset = $(this).offset().top;
        $('html, body').animate({
          scrollTop: offset - $(window).height() / 2
        }, 500, function() {
          $(self).parent().find('input').focus();
        });
        return false;
      }
    });
    return validated;
  }

  //Validity checks for username, password, email
  var passwordValid;
  //Check validity of username
  $('#username').on('keyup', function() {
    //Username Requirements:
    //At least 3 characters
    //Only numbers, letters, spaces, and .-_@+
    var username = $('#username').val();
    $('#username-valid').html('');
    var tooShort = (username.length < 3);
    var usernameRegex = /^[a-zA-Z0-9-+@_.\s]+$/
    var invalidChars = !(usernameRegex.test(username)) && username.length !== 0;

    if (tooShort || invalidChars) {
      if (tooShort) $('#username-valid').append('Username is too short (minimum is 3 characters).<br>');
      if (invalidChars) $('#username-valid').append('Username should use only letters, numbers, spaces, and .-_@+ please.');
      $('#username').css('borderColor', 'red');
    } else {
      $('#username').css('borderColor', '');
    }
  });

  //Check validity of email
  $('#email').on('keyup', function() {
    var emailVal = $('#email').val();
    //Email Regex
    var emailRegex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if (!emailRegex.test(emailVal)) {
      $('#email').css('borderColor', 'red');
      $('#email-valid').html('Email is invalid.');
    } else {
      $('#email').css('borderColor', '');
      $('#email-valid').html('');
    }
  });

  //Check validity of password
  $('#password').on('keyup', function() {
    //Password Requirement: 
    //At least 8 chars
    if ($('#password').val().length < 8) {
      $('#password-valid').html('Password is too short (minimum is 8 characters).');
      $('#password').css('borderColor', 'red');
      passwordValid = false;
      $('#password-confirmation').val('').prop('disabled', true);
    } else {
      $('#password-valid').html('');
      $('#password').css('borderColor', '');
      passwordValid = true;
      $('#password-confirmation').prop('disabled', false);
    }
  });

  //Check if passwords match; only checks when password is valid
  $('#password, #password-confirmation').on('keyup', function() {
    var matchText, matchColor, matchChk;
    if (passwordValid && ($('#password-confirmation').val().length || publicHasSubmitted)) {
      if ($('#password').val() === $('#password-confirmation').val()) {
        matchText = '&#10004 Passwords Match';
        matchColor = 'green';
        matchChk = true;
      } else {
        matchText = '&#10008 Passwords Do Not Match';
        matchColor = 'red';
        matchChk = false;
      }
      $('#password-match').html(matchText).css('color', matchColor).toggleClass('chk', matchChk);
      $('#password, #password-confirmation').css('borderColor', matchColor);
    } else {
      $('#password-match').html('');
      $('#password-confirmation').css('borderColor', '');
    }
  });
}());