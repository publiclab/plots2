$("document").ready(function() {
  $("input[name='user[username]']").on("change", function(e) {
    var username = e.target.value;
    if (username === "") {
      $(".username-check").empty();
    } else {
      $(".username-check").append(' <i class="fa fa-spinner fa-spin"></i>');
      $.get("/api/srch/profiles?query=" + username, function(data) {
        if (data.items) {
          $.map(data.items, function(userData) {
            if (userData.doc_title === username) {
              $(".username-check").empty();
              $(".username-check").append("Username already exists.");
              $(".username-check").css("color", "red");
            }
          });
        } else {
          $(".username-check").empty();
          $(".username-check").append("Username is available.");
          $(".username-check").css("color", "green");
        }
      });
    }
  });
});
