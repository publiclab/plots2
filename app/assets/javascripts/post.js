jQuery(document).ready(function() {

  $('.datepicker').datepicker()
  
  $E.initialize()

  $('#side-fileinput').bind('focus',function(e) { $('#side-dropzone').css('border-color','#4ac') })
  $('#side-fileinput').bind('focusout',function(e) { $('#side-dropzone').css('border-color','#ccc') })
  publish = function(e) {
    if ($('#main_image').val() == "" && $('#has_main_image').val() != "true" && !$D.warn_image) {
      // prompt to choose a lead image
      $D.warn_image = true;
      $('.side-dropzone').css('border-color','#d99')
      $('.side-dropzone').css('background','#fcc')
      alert_notice('Click <b>Publish</b> again to publish without a main image, but it is recommended that you add one.', {'scroll': true})
    } else {
      $('#new_drupal_node_revision').submit()
    }
  }
  $(".publish").bind("click",publish)
  $(".publish").bind("keydown",function(e) {
    if (e.which == 32 || e.which == 13) publish()
  })

  if ($E.textarea.val() == "") $E.apply_template(getUrlParameter('template') || "default")
  
  /* tag autocomplete */
  $('#taginput').typeahead({
    items: 8,
    minLength: 3,
    source: function (query, process) {
      var term = query.split(',').pop()
      if (term.length > 2) {
        return $.post('/tag/suggested/'+term, {}, function (data) {
          return process(data)
        })
      }
    },
    matcher: function() {
      return true
    },
    updater: function(text) { 
      original_text = $('#taginput').val().split(',')
      original_text.pop()
      original_text = original_text.join(',')
      if (original_text == '') return text
      else return original_text+','+text
    }
  });

})
