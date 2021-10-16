// this script is used wherever the legacy editor is used.
//   pages (wikis, questions, research notes) with multiple comments & editors for each comment
//   pages with JUST ONE form, and no other comments, eg. /wiki/new & /wiki/edit
//   /app/views/features/_form.html.erb
//   /app/views/map/edit.html.erb
//   and wherever /app/views/editor/editor.html.erb is still used in production

const progressAll = (elem, data) => {
  var progress = parseInt(data.loaded / data.total * 100, 10);
  $(elem).css(
    'width',
    progress + '%'
  );
}

// attach eventListeners on document.load for toolbar rich-text buttons & image upload .dropzones
$(function() {
  // for rich-text buttons (bold, italic, header, and link):
  $('.rich-text-button').on('click', function(e) {
    $E.setState(e.currentTarget.dataset.formId); // string that is: "main", "reply-123", "edit-123" etc.
    const action = e.currentTarget.dataset.action // 'bold', 'italic', etc.
    $E[action](); // call the appropriate editor function
  });

  // image upload event listeners for both:
  //   1. click-to-upload
  //   2. drag & drop
  // based on the basic plugin from jQuery file upload: 
  // https://github.com/blueimp/jQuery-File-Upload/wiki/Basic-plugin
  $('.dropzone').each(function() {
    // style changes for dragging an image over a dropzone
    $(this).on('dragenter',function(e) {
      e.preventDefault();
      $(e.currentTarget).addClass('hover');
    });

    $(this).on('dragleave',function(e) {
      $(e.currentTarget).removeClass('hover');
    });

    // runs on drag & drop
    $(this).on('drop',function(e) {
      e.preventDefault();
      $E.setState(e.currentTarget.dataset.formId); // string that is: "main", "reply-123", "edit-123" etc.
    });

    // disable drag-and-drop image upload on small dropzones
    // small dropzones are the image upload button in the comment form toolbar
    let dropZone = $(this);
    if ($(this).hasClass("dropzone-small")) {
      dropZone = null;
    }

    $(this).fileupload({
      url: "/images",
        paramName: "image[photo]",
        dropZone: dropZone,
        dataType: 'json',
        formData: {
          'uid':$D.uid,
          'nid':$D.nid
        },
        // 'start' function runs:
          //   1. when user drag-and-drops image
          //   2. when user clicks on upload button.
        start: function(e) {
          $E.setState(e.target.dataset.formId); // string that is: "main", "reply-123", "edit-123" etc.
          $(e.target).removeClass('hover');
          console.log($("#image-upload-progress-container-" + $E.commentFormID));
          $("#image-upload-progress-container-" + $E.commentFormID).show();
          $("#image-upload-text-" + $E.commentFormID).show();
          $("#choose-one-" + $E.commentFormID).hide();
        },
        done: function (e, data) {
          $("#image-upload-progress-container-" + $E.commentFormID).hide();
          $("#image-upload-text-" + $E.commentFormID).hide();
          $("#choose-one-" + $E.commentFormID).show();
          $("#image-upload-progress-bar-" + $E.commentFormID).css('width', 0);
          var extension = data.result['filename'].split('.')[data.result['filename'].split('.').length - 1]; var file_url = data.result.url.split('?')[0]; var file_type;
          if (['gif', 'GIF', 'jpeg', 'JPEG', 'jpg', 'JPG', 'png', 'PNG'].includes(extension))
            file_type = 'image'
          else if (['csv', 'CSV'].includes(extension))
            file_type = 'csv'
          switch (file_type) {
            case 'image':
              orig_image_url = file_url + '?s=o' // size = original
              $E.wrap('[![', '](' + file_url + ')](' + orig_image_url + ')', true, data.result['filename']);
              break;
            case 'csv':
              $E.wrap('[graph:' + file_url + ']', '', true);
              break;
            default:
              $E.wrap('<a href="'+data.result.url.split('?')[0]+'"><i class="fa fa-file"></i> ', '</a>', true, data.result['filename'].replace(/[()]/g , "-")); // on its own line; see /app/assets/js/editor.js
          }
          // here append the image id to the wiki edit form:
          if ($('#node_images').val() && $('#node_images').val().split(',').length > 1) $('#node_images').val([$('#node_images').val(),data.result.id].join(','))
          else $('#node_images').val(data.result.id)
        },
        fileuploadfail: function(e, data) {
          console.log(e);
        },
        progressall: function (e, data) {
          const closestProgressBar = $("#image-upload-progress-bar-" + $E.commentFormID);
          return progressAll(closestProgressBar, data);
        }
    });
  });

  // #side-dropzone, is for the main image of research notes, in /app/views/editor/post.html.erb
  $('#side-dropzone').on('dragover',function(e) {
    e.preventDefault();
    $('#side-dropzone').addClass('hover');
  });
  $('#side-dropzone').on('dragout',function(e) {
    $('#side-dropzone').removeClass('hover');
  });
  $('#side-dropzone').on('drop',function(e) {
    e.preventDefault();
  });

  $('#side-dropzone').fileupload({
    url: "/images",
    paramName: "image[photo]",
    dropZone: $('#side-dropzone'),
    dataType: 'json',
    formData: {
      'uid':$D.uid,
      'nid':$D.nid
    },
    start: function(e) {
      $('.side-dropzone').css('border-color','#ccc');
      $('.side-dropzone').css('background','none');
      $('#side-progress').show();
      $('#side-dropzone').removeClass('hover');
      $('.side-uploading').show();
    },
    done: function (e, data) {
      $('#side-progress').hide();
      $('#side-dropzone').show();
      $('.side-uploading').hide();
      $('#leadImage')[0].src = data.result.url;
      $('#leadImage').show();
      // here append the image id to the note as the lead image
      $('#main_image').val(data.result.id);
      $("#image_revision").append('<option selected="selected" id="'+data.result.id+'" value="'+data.result.url+'">Temp Image '+data.result.id+'</option>');
    },
    fileuploadfail: function(e, data) {
      console.log(e);
    },
    progressall: function (e, data) {
      return progressAll('#side-progress .progress-bar', data);
    }
  });
});
