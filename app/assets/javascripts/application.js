//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require jquery-fileupload


//$(function(){ $(document).foundation(); });



// $ ->
//   $('.datetimepicker').fdatetimepicker({
//     language: 'zh'
//   });


$('.submit-button').on('click', function(){
  $(this).parent().submit();
})