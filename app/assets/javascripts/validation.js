$(document).ready(function() {
  $("#edit-form").validate({
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
        equalTo: "#password1"
      }
    },
    messages: {
      password1: {
        required: "Please enter password",
        minlength: "Password should be minimum 8 characters long"
      },
      email: {
        required: "Please enter email",
        email: "Invalid email address"
      },
      password2: {
        required: "Please enter password",
        minlength: "Password should be minimum 8 characters long",
        equalTo: "Passwords doesn't match"
      }
    },
    submitHandler: function(form) {
      form.submit();
    }
  });
});

$(document).ready(function() {
  // The two forms have the same ID
  var signUpForms = document.querySelectorAll("#create-form");
  var signUpErrorMessages = document.querySelector("#error-message");

  // Sign up modal form
  signUpForms[0].classList.add("signup-modal-form");
  var signUpModalForm = new SignUpFormValidator(".signup-modal-form");
  // publiclab.org/register form
  if (signUpForms[1]) {
    signUpForms[1].classList.add("signup-register-form");
    var signUpRegisterForm = new SignUpFormValidator(".signup-register-form");

    if (signUpErrorMessages.innerHTML.includes("error")) {
      signUpRegisterForm.updateUI(signUpRegisterForm.emailElement, true);
      signUpRegisterForm.updateUI(signUpRegisterForm.usernameElement, true);
      if (signUpErrorMessages.innerHTML.includes("Email")) {
        signUpRegisterForm.updateUI(signUpRegisterForm.emailElement, false, "Email already exists");
      }
      if (signUpErrorMessages.innerHTML.includes("Username")) {
        signUpRegisterForm.updateUI(signUpRegisterForm.usernameElement, false, "Username already exists");
      }
    }
  }

  // The same goes for login forms
  var loginForms = document.querySelectorAll(".user-sessions-form");

  loginForms[0].classList.add("login-modal-form");
  LoginFormValidator(".login-modal-form");

  // publiclab.org/login form
  if (loginForms[1]) {
    loginForms[1].classList.add("login-page-form");
    LoginFormValidator(".login-page-form");
  }
});

// The main login form validation function
function LoginFormValidator(formSelector) {
  var loginForm = document.querySelector(formSelector);

  loginForm.addEventListener("submit", handleLoginFormValidation);
}

function handleLoginFormValidation(e) {
  var formSelector = this.classList.value.split(" ").join(".");
  e.preventDefault();

  var usernameElement = document.querySelector(
    formSelector + " #username-login"
  );
  var passwordElement = document.querySelector(
    formSelector + " #password-signup"
  );

  var username = usernameElement.value.trim();
  var password = passwordElement.value.trim();

  var isUsernameValid = username.length >= 3;

  if (isUsernameValid && isPasswordValid(password)) {
    removeLoginFormError(formSelector);
    renderSubmitBtnSpinner(formSelector);
    this.submit();
  } else {
    renderLoginFormError(formSelector);
  }
}

function renderSubmitBtnSpinner(formSelector) {
  var submitFormBtn = document.querySelector(formSelector + " #login-button");

  submitFormBtn.classList.add("disabled");
  submitFormBtn.innerHTML = '<i class="fa fa-spinner fa-spin"></i>';
}

function renderLoginFormError(formSelector) {
  removeLoginFormError(formSelector);

  var loginFormWrapper = document.querySelector(formSelector + " .login-form");

  var errorMessageHTML =
    '<div class="alert alert-danger error-msg-container" style="margin: 0 18px;">\
      <button type="button" class="close" data-dismiss="alert">\
        ×\
      </button>\
      Invalid username or password\
      </div>';

  loginFormWrapper.insertAdjacentHTML("beforeBegin", errorMessageHTML);
}

function removeLoginFormError(formSelector) {
  var loginFormErrorElement = document.querySelector(
    formSelector + " .error-msg-container"
  );

  if (loginFormErrorElement) {
    loginFormErrorElement.remove();
  }
}

// Sign Up form validation class
function SignUpFormValidator(formClass) {
  var signUpForm = document.querySelector(formClass);

  if (!signUpForm) return;

  this.validationTracker = {};

  this.submitBtn = document.querySelector(formClass + ' [type="submit"]');

  this.isFormValid();

  this.usernameElement = document.querySelector(
    formClass + " [name='user[username]']"
  );
  this.emailElement = document.querySelector(
    formClass + " [name='user[email]']"
  );
  this.passwordElement = document.querySelector(
    formClass + " [name='user[password]']"
  );
  this.confirmPasswordElement = document.querySelector(
    formClass + " [name='user[password_confirmation]']"
  );

  // Every time user types something, corresponding event listener are triggered
  this.usernameElement.addEventListener(
    "input",
    validateUsername.bind(this.usernameElement, this)
  );
  this.emailElement.addEventListener(
    "input",
    validateEmail.bind(this.emailElement, this)
  );
  this.passwordElement.addEventListener(
    "input",
    validatePassword.bind(this.passwordElement, this.confirmPasswordElement, this)
  );
  this.confirmPasswordElement.addEventListener(
    "input",
    validateConfirmPassword.bind(this.confirmPasswordElement, this.passwordElement, this)
  );
}

// Typing the form triggers the function
// Updates UI depending on the value of <valid> parameter
SignUpFormValidator.prototype.updateUI = function(element, valid, errorMsg) {
  var elementName = element.getAttribute("name");

  if (valid) {
    this.validationTracker[elementName] = true;
    styleElement(element, "form-element-invalid", "form-element-valid");
    removeErrorMsg(element);
  } else {
    this.validationTracker[elementName] = false;
    styleElement(element, "form-element-valid", "form-element-invalid");
    renderErrorMsg(element, errorMsg);
  }

  this.isFormValid();
};

SignUpFormValidator.prototype.disableSubmitBtn = function() {
  this.submitBtn.setAttribute("disabled", "");
};

SignUpFormValidator.prototype.enableSubmitBtn = function() {
  this.submitBtn.removeAttribute("disabled");
};

SignUpFormValidator.prototype.validateForm = function() {
  validateUsername.call(this.usernameElement, this)
  validateEmail.call(this.emailElement, this)
  validatePassword.call(this.passwordElement, this.confirmPasswordElement, this)
  validateConfirmPassword.call(this.confirmPasswordElement, this.passwordElement, this)
};

SignUpFormValidator.prototype.isFormValid = function() {
  // Form is valid if all elements have passsed validation successfully
  var isValidForm =
    Object.values(this.validationTracker).filter(Boolean).length === 4;

  if (isValidForm) this.enableSubmitBtn();
  else this.disableSubmitBtn();
};

function validateUsername(obj) {
  var username = this.value.trim();
  var self = this;

  if (username.length < 3) {
    obj.updateUI(this, false, "Username has to be at least 3 characters long");
  } else {
    $.get("/api/srch/profiles?query=" + username, function(data) {
      if (data.items) {
        $.map(data.items, function(userData) {
          if (userData.doc_title === username) {
            obj.updateUI(self, false, "Username already exists");
          } else {
            obj.updateUI(self, true);
          }
        });
      } else {
        obj.updateUI(self, true);
      }
    });
  }
}

function validateEmail(obj) {
  var email = this.value.trim();

  if (email.length === 0) {
    obj.updateUI(this, false, "The email cannot be empty.");
    return;
  }

  var emailRegExp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  var isValidEmail = emailRegExp.test(email);

  obj.updateUI(this, isValidEmail, "Invalid email");
}

function validatePassword(confirmPasswordElement, obj) {

  var password = this.value.trim();

  if (password.length === 0) {
    obj.updateUI(this, false, "The password cannot be empty.");
    return;
  }

  if (!isPasswordValid(password)) {
    obj.updateUI(
      this,
      false,
      "Please make sure password is at least 8 characters long"
    );
    return;
  }

  if (password === confirmPasswordElement.value) {
    obj.updateUI(confirmPasswordElement, true);
  }

  obj.updateUI(this, true);
}

function validateConfirmPassword(passwordElement, obj) {
  var confirmPassword = this.value.trim();
  var password = passwordElement.value;

  if (confirmPassword.length === 0) {
    obj.updateUI(this, false, "The password confirmation cannot be empty");
    return;
  }

  if (confirmPassword !== password || !isPasswordValid(password)) {
    obj.updateUI(
      this,
      false,
      "Password and Password Confirmation should be the same"
    );
    return;
  }

  obj.updateUI(this, true);
}

// Password is valid if it is at least 8 characaters long and contains a number
// Password's validation logic, no UI updates
function isPasswordValid(password) {
  var isValidPassword = password.length >= 8;

  return isValidPassword;
}

function renderErrorMsg(element, message) {
  if (!message) return;

  // Error messages are rendered inside of a <small> HTML element
  var errorMsgElement = element.nextElementSibling;
  if (!errorMsgElement) {
    // On publiclab.org/register invalid elements are wrapped in a div.
    errorMsgElement = element.parentElement.nextElementSibling;
  }

  errorMsgElement.textContent = message;
  errorMsgElement.style.color = "red";
  errorMsgElement.classList.remove("invisible");
}

function removeErrorMsg(element) {
  var errorMsgElement = element.nextElementSibling;
  if (!errorMsgElement) {
    errorMsgElement = element.parentElement.nextElementSibling;
  }

  errorMsgElement.classList.add("invisible");
}

function restoreOriginalStyle(element) {
  element.classList.remove("form-element-valid");
  element.classList.remove("form-element-invalid");
}

// Makes input element red or green
function styleElement(element, classToRemove, classToAdd) {
  if (element.classList.contains(classToRemove)) {
    element.classList.remove(classToRemove);
  }

  element.classList.add(classToAdd);
}
