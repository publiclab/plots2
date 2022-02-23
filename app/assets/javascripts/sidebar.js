function toggle_sidebar() {
  $(".accordion button").attr("aria-expanded", function (index, attr) {
    return attr === "false" ? "true" : "false";
  });
}
