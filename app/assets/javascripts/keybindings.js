$(document).ready(function () {
    $(window).on('keypress', function (e) {
        if (e.which === 47) {
            $('#searchform_input').focus();
            e.preventDefault();
        }
    });
});