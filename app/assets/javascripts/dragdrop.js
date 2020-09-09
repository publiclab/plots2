jQuery(document).ready(function() {
/*
 * Based on the basic plugin from jQuery file upload: 
 * https://github.com/blueimp/jQuery-File-Upload/wiki/Basic-plugin
 *
 * .dropzone is for inline images for both wiki and research notes, in:
 *   /app/views/editor/_editor.html.erb
 *   /app/views/wiki/edit.html.erb
 * #side-dropzone, is for the main image of research notes, in /app/views/editor/post.html.erb
*/

    function progressAll(elem, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $(elem).css(
            'width',
            progress + '%'
        );
    }

    $('.dropzone').bind('dragover',function(e) {
      e.preventDefault();
      $('.dropzone').addClass('hover');
    });
    $('#side-dropzone').bind('dragover',function(e) {
      e.preventDefault();
      $('#side-dropzone').addClass('hover');
    });
    $('.dropzone').bind('dragout',function(e) {
      $('.dropzone').removeClass('hover');
    });
    $('#side-dropzone').bind('dragout',function(e) {
      $('#side-dropzone').removeClass('hover');
    });
    $('.dropzone').bind('drop',function(e) {
      $D.selected = $(e.target.closest('div.comment-form-wrapper')).eq(0);
      e.preventDefault();
      $E.initialize({});
    });
    $('#side-dropzone').bind('drop',function(e) {
      e.preventDefault();
    });

    $('.dropzone').each(function () {
        $(this).fileupload({
            url: "/images",
            paramName: "image[photo]",
            dropZone: $(this),
            dataType: 'json',
            formData: {
                'uid':$D.uid,
                'nid':$D.nid
            },
            start: function(e) {
                $('#imagebar .inline_image_drop').show();
                $('#create_progress').show();
                $('#create_uploading').show();
                elem = $($D.selected).closest('div.comment-form-wrapper').eq(0);
                elem.find('#create_progress').eq(0).show();
                elem.find('#create_uploading').eq(0).show();
                elem.find('#create_prompt').eq(0).hide();
                elem.find('.dropzone').eq(0).removeClass('hover');
            },
            done: function (e, data) {
                $('#create_progress').hide();
                $('#create_uploading').hide();
                $('#imagebar .inline_image_drop').hide();
                elem = $($D.selected).closest('div.comment-form-wrapper').eq(0);
                elem.find('#create_progress').hide();
                elem.find('#create_uploading').hide();
                elem.find('#create_prompt').show();
                var extension = data.result['filename'].split('.')[data.result['filename'].split('.').length - 1]; var file_url = data.result.url.split('?')[0]; var file_type;
                if (['gif', 'GIF', 'jpeg', 'JPEG', 'jpg', 'JPG', 'png', 'PNG'].includes(extension))
                    file_type = 'image'
                else if (['csv', 'CSV'].includes(extension))
                    file_type = 'csv'
                switch (file_type) {
                    case 'image':
                        orig_image_url = file_url + '?s=o' // size = original
                        $E.wrap('[![', '](' + file_url + ')](' + orig_image_url + ')', {'newline': true, 'fallback': data.result['filename']}) // on its own line; see /app/assets/js/editor.js
                        break
                    case 'csv':
                        $E.wrap('[graph:' + file_url + ']', '', {'newline': true})
                        break
                    default:
                        $E.wrap('<a href="'+data.result.url.split('?')[0]+'"><i class="fa fa-file"></i> ','</a>', {'newline': true, 'fallback': data.result['filename'].replace(/[()]/g , "-")}) // on its own line; see /app/assets/js/editor.js
                }
                // here append the image id to the wiki edit form:
                if ($('#node_images').val() && $('#node_images').val().split(',').length > 1) $('#node_images').val([$('#node_images').val(),data.result.id].join(','))
                else $('#node_images').val(data.result.id)
                // eventual handling of multiple files; must add "multiple" to file input and handle on server side:
                //$.each(data.result.files, function (index, file) {
                //    $('<p/>').text(file.name).appendTo(document.body);
                //});
            },

            // see callbacks at https://github.com/blueimp/jQuery-File-Upload/wiki/Options
            fileuploadfail: function(e,data) {

            },
            progressall: function (e, data) {
                return progressAll('#create_progress .progress-bar', data);
            }
        });
    });

    // $('.dropzone').off('drop').on('drop', function (e) {
    //     e.preventDefault();
    //     elem = $(e.target.closest('div.comment-form-wrapper')).find('.dropzone').eq(0);
    //     $D.selected = $(e.target.closest('div.comment-form-wrapper'));
    //     uploadImage(elem);
    // });
    //
    // $('input[type="file"]').off().on('change', function (e) {
    //     e.preventDefault();
    //     elem = $(e.target.closest('div.comment-form-wrapper')).find('.dropzone').eq(0);
    //     uploadImage(elem);
    // });
    //
    //
    // function uploadImage(elem) {
    //     elem.fileupload({
    //         url: "/images",
    //         paramName: "image[photo]",
    //         dropZone: $('.dropzone'),
    //         dataType: 'json',
    //         formData: {
    //             'uid':$D.uid,
    //             'nid':$D.nid
    //         },
    //         start: function(e) {
    //             if($D.selected) {
    //                 ($D.selected).find('#create_progress').eq(0).show();
    //                 ($D.selected).find('#create_uploading').eq(0).show();
    //                 ($D.selected).find('#create_prompt').eq(0).hide();
    //                 ($D.selected).find('.dropzone').eq(0).removeClass('hover');
    //             }
    //         },
    //         done: function (e, data) {
    //             if($D.selected) {
    //                 ($D.selected).find('#create_progress').hide();
    //                 ($D.selected).find('#create_uploading').hide();
    //                 ($D.selected).find('#create_prompt').show();
    //             }
    //             var extension = data.result['filename'].split('.')[data.result['filename'].split('.').length - 1]
    //             var file_url = data.result.url.split('?')[0]
    //
    //             var file_type
    //             if (['gif', 'GIF', 'jpeg', 'JPEG', 'jpg', 'JPG', 'png', 'PNG'].includes(extension))
    //                 file_type = 'image'
    //             else if (['csv', 'CSV'].includes(extension))
    //                 file_type = 'csv'
    //
    //             switch (file_type) {
    //                 case 'image':
    //                     orig_image_url = file_url + '?s=o' // size = original
    //                     $E.wrap('[![', '](' + file_url + ')](' + orig_image_url + ')', {'newline': true, 'fallback': data.result['filename']}) // on its own line; see /app/assets/js/editor.js
    //                     break
    //                 case 'csv':
    //                     $E.wrap('[graph:' + file_url + ']', {'newline': true, 'fallback': data.result['filename']})
    //                     break
    //                 default:
    //                     $E.wrap('<a href="'+data.result.url.split('?')[0]+'"><i class="fa fa-file"></i> ','</a>', {'newline': true, 'fallback': data.result['filename'].replace(/[()]/g , "-")}) // on its own line; see /app/assets/js/editor.js
    //             }
    //
    //             // here append the image id to the wiki edit form:
    //             if ($('#node_images').val() && $('#node_images').val().split(',').length > 1) $('#node_images').val([$('#node_images').val(),data.result.id].join(','))
    //             else $('#node_images').val(data.result.id)
    //
    //             // eventual handling of multiple files; must add "multiple" to file input and handle on server side:
    //             //$.each(data.result.files, function (index, file) {
    //             //    $('<p/>').text(file.name).appendTo(document.body);
    //             //});
    //         },
    //
    //         // see callbacks at https://github.com/blueimp/jQuery-File-Upload/wiki/Options
    //         fileuploadfail: function(e,data) {
    //
    //         },
    //         progressall: function (e, data) {
    //             var progress = parseInt(data.loaded / data.total * 100, 10);
    //             $('#create_progress-bar').css(
    //                 'width',
    //                 progress + '%'
    //             );
    //         }
    //     });
    // }


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

      // see callbacks at https://github.com/blueimp/jQuery-File-Upload/wiki/Options
      fileuploadfail: function(e,data) {
      },
      progressall: function (e, data) {
          return progressAll('#side-progress .progress-bar', data);
      }
    });
});
