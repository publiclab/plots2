$(document).ready(function() {
  $('#edit-form').validate({
    rules: {
      email: {
        required: true,
        email: true
      },
      password1: {
        required: true,
        minlength: 8
      },
      password2: {
        equalTo: '#password1'
      }
    },
    messages: {
      password1: {
        required: 'Please enter password',
        minlength: 'Password should be minimum 8 characters long'
      },
      email: {
        required: 'Please enter email',
        email: 'Invalid email address'
      },
      password2: {
        required: 'Please enter password',
        minlength: 'Password should be minimum 8 characters long',
        equalTo: "Passwords doesn't match"
      }
    },
    submitHandler: function(form) {
      form.submit();
    }
  });
});

$(document).ready(function () {
  var signUpForm = document.querySelector('#create-form');

  if (!signUpForm) return;

  var validationTracker = {};
  var submitBtn = document.querySelector("#create-form [type='submit']");
  var usernameElement = document.querySelector("[name='user[username]']");
  var emailElement = document.querySelector("[name='user[email]']");
  var passwordElement = document.querySelector("[name='user[password]']");
  var confirmPasswordElement = document.querySelector(
    "[name='user[password_confirmation]']"
  );

  isFormValid();

  // Every time user types something, it triggers corresponding event listener
  usernameElement.addEventListener('input', validateUsername);
  emailElement.addEventListener('input', validateEmail);
  passwordElement.addEventListener('input', validatePassword);
  confirmPasswordElement.addEventListener('input', validateConfirmPassword);

  function validateUsername(e) {
    var username = e.target.value;

    if (username.length < 3) {
      restoreOriginalStyle(this);
    } else {
      $.get('/api/srch/profiles?query=' + username, function(data) {
        if (data.items) {
          $.map(data.items, function(userData) {
            if (userData.doc_title === username) {
              updateUI(usernameElement, false, 'Username already exists');
            } else {
              updateUI(usernameElement, true);
            }
          });
        } else {
          updateUI(usernameElement, true);
        }
      });
    }
  }

  function validateEmail(e) {
    var email = e.target.value;
    var regexp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    var isValid = regexp.test(email);

    updateUI(emailElement, isValid, 'Invalid email');
  }

  function validatePassword(e) {
    var password = e.target.value;

    if (!isPasswordValid(password)) {
      updateUI(this, false, 'Minimum 8 characters including 1 number');
      return;
    }

    if (password === confirmPasswordElement.value) {
      updateUI(confirmPasswordElement, true);
    }

    updateUI(passwordElement, true);
  }

  function validateConfirmPassword(e) {
    var password = passwordElement.value;
    var confirmPassword = e.target.value;

    if (!isPasswordValid(confirmPassword)) {
      updateUI(this, false, 'Minimum 8 characters including 1 number');
      return;
    }

    if (confirmPassword !== password) {
      updateUI(confirmPasswordElement, false, 'Passwords must be equal');
      return;
    }

    updateUI(confirmPasswordElement, true);
  }

  // Password is valid if it is at least 8 characaters long and contains a number
  // This is password's validation logic, no UI
  function isPasswordValid(element, password) {
    var doesContainNum = /\d+/g.test(password);
    var isValid = password.length >= 8 && doesContainNum;

    return isValid;
  }

  // Every time user types something in the form, it triggers this function
  // It will update UI depending on the value of <valid> parameter
  function updateUI(element, valid, errorMsg) {
    var elementName = element.getAttribute('name');

    if (valid) {
      validationTracker[elementName] = true;
      styleElement(element, 'form-element-invalid', 'form-element-valid');
      removeErrorMsg(element);
    } else {
      validationTracker[elementName] = false;
      styleElement(element, 'form-element-valid', 'form-element-invalid');
      renderErrorMsg(element, errorMsg);
    }

    isFormValid();
  }

  function renderErrorMsg(element, message) {
    if (!message) return;

    // Error messages are rendered inside of a <small> HTML element
    var errorMsgElement = element.nextElementSibling;
    errorMsgElement.textContent = message;
    errorMsgElement.style.color = 'red';
    errorMsgElement.classList.remove('invisible');
  }

  function removeErrorMsg(element) {
    var errorMsgElement = element.nextElementSibling;
    errorMsgElement.classList.add('invisible');
  }

  function restoreOriginalStyle(element) {
    element.classList.remove('form-element-valid');
    element.classList.remove('form-element-invalid');
  }

  // Makes input element red/green
  function styleElement(element, classToRemove, classToAdd) {
    if (element.classList.contains(classToRemove)) {
      element.classList.remove(classToRemove);
    }

    element.classList.add(classToAdd);
  }

  function disableSubmitBtn() {
    submitBtn.setAttribute('disabled', '');
  }

  function enableSubmitBtn() {
    submitBtn.removeAttribute('disabled');
  }

  function isFormValid() {
    // Form is valid if all elements have passsed validation successffully
    var isValid = Object.values(validationTracker).filter(Boolean).length === 4;

    if (isValid) enableSubmitBtn();
    else disableSubmitBtn();
  }
});
