var previewNode = document.querySelector("#template");
var previewTemplate = previewNode.parentNode.innerHTML;


Dropzone.options.myDropzone = {
maxFilesize: 2, // MB
addRemoveLinks: true,
thumbnailWidth: 40,
thumbnailHeight: 40,
maxFiles: 10,
dictDefaultMessage: "<div class='button success' sytle='background-color:#008CBA;'><i class="fa fa-plus-circle"></i><i class="fa fa-picture-o"></i></div>",

  // Prevents Dropzone from uploading dropped files immediately
  autoProcessQueue: true,

  init: function() {
    var submitButton = document.querySelector("#submit-all")
        myDropzone = this; // closure

    //submitButton.addEventListener("click", function() {
      //myDropzone.processQueue(); // Tell Dropzone to process all queued files.
   // });

    // You might want to show the submit button only when 
    // files are dropped here:
    this.on("addedfile", function() {
      // Show submit button here and/or inform user to click it.
    });

    this.on('success', function(file, e){
      $('.dz-image').each(function(){
        if($(this).attr('id') == undefined) {
          $(this).attr('id', e);
          return false;
        }
      });
      ids = $('.pic-ids').val();
      if(ids.length == 0) {
        $('.pic-ids').val(e);
      }
      else {
        ids = ids + ',' + e;
        $('.pic-ids').val(ids);
      }
    });

    this.on('removedfile', function(file) {
      var ids = [];
      if($('.dz-image').length > 0) {
        $('.dz-image').each(function(){
          ids.push($(this).attr('id'));
        });
      }
      $('.pic-ids').val(ids.join(','));
    });

  }
};
