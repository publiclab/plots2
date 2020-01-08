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
  // The two forms have same ID
  var signUpForms = document.querySelectorAll("#create-form");

  // Sign up modal form
  signUpForms[0].classList.add("signup-modal-form");
  SignUpFormValidator(".signup-modal-form");

  // publiclab.org/register form
  if (signUpForms[1]) {
    signUpForms[1].classList.add("signup-register-form");
    SignUpFormValidator(".signup-register-form");
  }

  LoginFormValidator(".login-form");
});

// Login Form validation function
function LoginFormValidator(formClass) {
  var formValidator = new FormValidator(formClass, 2);
  formValidator.isLoginForm = true;

  var usernameElement = document.querySelector(formClass + " #username-login");
  var passwordElement = document.querySelector(formClass + " #password-signup");

  usernameElement.addEventListener(
    "input",
    formValidator.validateUsername.bind(usernameElement, formValidator)
  );
  passwordElement.addEventListener(
    "input",
    formValidator.validatePassword.bind(passwordElement, {}, formValidator)
  );
}

// Sign Up Form validation function
function SignUpFormValidator(formClass) {
  var formValidator = new FormValidator(formClass, 4);

  var usernameElement = document.querySelector(
    formClass + " [name='user[username]']"
  );
  var emailElement = document.querySelector(
    formClass + " [name='user[email]']"
  );
  var passwordElement = document.querySelector(
    formClass + " [name='user[password]']"
  );
  var confirmPasswordElement = document.querySelector(
    formClass + " [name='user[password_confirmation]']"
  );

  // Every time user types something, corresponding event listener are triggered
  usernameElement.addEventListener(
    "input",
    formValidator.validateUsername.bind(usernameElement, formValidator)
  );
  emailElement.addEventListener(
    "input",
    formValidator.validateEmail.bind(emailElement, formValidator)
  );
  passwordElement.addEventListener(
    "input",
    formValidator.validatePassword.bind(
      passwordElement,
      confirmPasswordElement,
      formValidator
    )
  );
  confirmPasswordElement.addEventListener(
    "input",
    formValidator.validateConfirmPassword.bind(
      confirmPasswordElement,
      passwordElement,
      formValidator
    )
  );
}

// Universal form validation class
function FormValidator(formClass, elementsToValidate) {
  var form = document.querySelector(formClass);

  if (!form) return;

  this.validationTracker = {};
  this.elementsToValidate = elementsToValidate;
  this.submitBtn = document.querySelector(formClass + ' [type="submit"');

  this.isFormValid();
}

// Typing the form triggers the function
// Updates UI depending on the value of <valid> parameter
FormValidator.prototype.updateUI = function(element, valid, errorMsg) {
  var elementName = element.getAttribute("name");

  if (valid) {
    this.validationTracker[elementName] = true;
    this.styleElement(element, "form-element-invalid", "form-element-valid");
    this.removeErrorMsg(element);
  } else {
    this.validationTracker[elementName] = false;
    this.styleElement(element, "form-element-valid", "form-element-invalid");
    this.renderErrorMsg(element, errorMsg);
  }

  this.isFormValid();
};

FormValidator.prototype.disableSubmitBtn = function() {
  this.submitBtn.setAttribute("disabled", "");
};

FormValidator.prototype.enableSubmitBtn = function() {
  this.submitBtn.removeAttribute("disabled");
};

FormValidator.prototype.isFormValid = function() {
  // Form is valid if all elements have passsed validation successfully
  var isValidForm =
    Object.values(this.validationTracker).filter(Boolean).length ===
    this.elementsToValidate;

  if (isValidForm) this.enableSubmitBtn();
  else this.disableSubmitBtn();
};

FormValidator.prototype.validateUsername = function(formValidator) {
  var username = this.value;
  var self = this;

  if (username.length < 3) {
    formValidator.restoreOriginalStyle(this);
    formValidator.disableSubmitBtn();
    formValidator.removeErrorMsg(self);
  } else {
    $.get("/api/srch/profiles?query=" + username, function(data) {
      if (data.items) {
        $.map(data.items, function(userData) {
          if (formValidator.isLoginForm) {
            // Login form username validation
            formValidator.validateLoginUsername(userData, username, self);
          } else {
            // Sign up form username validation
            formValidator.validateSignUpUsername(userData, username, self);
          }
        });
      } else {
        formValidator.updateUI(self, true);
      }
    });
  }
};

FormValidator.prototype.validateLoginUsername = function(
  userData,
  username,
  usernameElement
) {
  if (userData.doc_title === username) this.updateUI(usernameElement, true);
  else this.updateUI(usernameElement, false, "Username doesn't exist");
};

FormValidator.prototype.validateSignUpUsername = function(
  userData,
  username,
  usernameElement
) {
  if (userData.doc_title === username)
    this.updateUI(usernameElement, false, "Username already exists");
  else this.updateUI(usernameElement, true);
};

FormValidator.prototype.validateEmail = function(formValidator) {
  var email = this.value;
  var emailRegExp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  var isValidEmail = emailRegExp.test(email);

  formValidator.updateUI(this, isValidEmail, "Invalid email");
};

FormValidator.prototype.validatePassword = function(
  confirmPasswordElement,
  formValidator
) {
  var password = this.value;

  if (!formValidator.isPasswordValid(password)) {
    formValidator.updateUI(
      this,
      false,
      "Please make sure password is at least 8 characters long with minimum one numeric value"
    );
    return;
  }

  if (password === confirmPasswordElement.value) {
    formValidator.updateUI(confirmPasswordElement, true);
  }

  formValidator.updateUI(this, true);
};

FormValidator.prototype.validateConfirmPassword = function(
  passwordElement,
  formValidator
) {
  var confirmPassword = this.value;
  var password = passwordElement.value;

  if (!formValidator.isPasswordValid(confirmPassword)) {
    formValidator.updateUI(
      this,
      false,
      "Please make sure password is at least 8 characters long with minimum one numeric value"
    );
    return;
  }

  if (confirmPassword !== password) {
    formValidator.updateUI(this, false, "Passwords must be equal");
    return;
  }

  formValidator.updateUI(this, true);
};

// Password is valid if it is at least 8 characaters long and contains a number
// Password's validation logic, no UI updates
FormValidator.prototype.isPasswordValid = function(password) {
  var doesContainNumber = /\d+/g.test(password);
  var isValidPassword = password.length >= 8 && doesContainNumber;

  return isValidPassword;
};

FormValidator.prototype.renderErrorMsg = function(element, message) {
  if (!message) return;

  var errorMsgElement = document.querySelector("#" + element.id + "~ small");

  errorMsgElement.textContent = message;
  errorMsgElement.style.color = "red";
  errorMsgElement.classList.remove("invisible");
};

FormValidator.prototype.removeErrorMsg = function(element) {
  var errorMsgElement = document.querySelector("#" + element.id + "~ small");
  if (!errorMsgElement) return;

  errorMsgElement.classList.add("invisible");
};

FormValidator.prototype.restoreOriginalStyle = function(element) {
  element.classList.remove("form-element-valid");
  element.classList.remove("form-element-invalid");
};

// Makes input element red or green
FormValidator.prototype.styleElement = function(
  element,
  classToRemove,
  classToAdd
) {
  if (element.classList.contains(classToRemove)) {
    element.classList.remove(classToRemove);
  }

  element.classList.add(classToAdd);
};
