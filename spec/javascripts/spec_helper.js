// Teaspoon includes some support files, but you can use anything from your own support path too.
//= require support/expect
//= require support/sinon
//= require support/chai
//= require jquery

// You can require your own javascript files here. By default this will include everything in application, however you
// may get better load performance if you require the specific files that are being used in the spec that tests them.
//= require application

window.assert = chai.assert;
window.expect = chai.expect;
window.should = chai.should();
