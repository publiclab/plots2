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

function publicSpamCompletedChange() {
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
}

if (publicUsingSpamaway) {
  $('.spamaway button').click(function(e) {
    $(this).find('input').prop('checked', true);
    console.log('working');
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
    publicHasSubmitted = true;

    if (!publicSpamCompleted) { //needs to still highlight
      e.preventDefault();
      publicSpamCompletedChange();
    }

    $('.form-control').trigger('keyup'); //Prevents bypassing check when all fields have not been touched
    var validated = checkValidation();

    if (publicSpamCompleted && validated) {
      $(this).addClass("disabled") // disable the button after it is clicked
        .html("<i class='fa fa-spinner fa-spin'></i>"); // make a spinner that spins when clicked
    }
  });

  //Check that all are valid
  function checkValidation() {
    $('.validate').each(function() {
      var validated = true;
      if ($(this).html() !== '' && !this.classList.contains('chk')) { //Check that all messages are clear
        validated = false;
        offset = $(this).offset().top;
        $('html, body').animate({
          scrollTop: offset.top - $(window).height() / 2
        }, 500);
        $(this).parent().find('input').focus();
        return false;
      }
      return validated;
    })
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
    var invalidChars = !(new RegExp('^[a-zA-Z0-9-+@_.]+$').test(username)) && username.length !== 0;

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
    //Email Regex
    var emailRegex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if (!emailRegex.test($('#email').val())) {
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
    if (passwordValid) {
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