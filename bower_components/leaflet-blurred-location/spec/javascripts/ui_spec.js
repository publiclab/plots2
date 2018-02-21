describe("UI testing", function() {
  "use strict";

  it("Checks if input listeners change maps position to the entered latitude and longitude", function() {
    var fixture = loadFixtures('index.html');

    var latEl = $("#lat");
    var lngEl = $("#lng");

    latEl.val(20);
    lngEl.val(15);

    expect(parseFloat(latEl.val())).toBe(20);
    expect(parseFloat(lngEl.val())).toBe(15);

    latEl.change();

    expect(blurredLocation.getLat()).toBe(20);
    expect(blurredLocation.getLon()).toBe(15);

    latEl.val(2);
    lngEl.val(23);

    latEl.change();

    expect(blurredLocation.getLat()).toBe(2);
    expect(blurredLocation.getLon()).toBe(23);
  });
});
