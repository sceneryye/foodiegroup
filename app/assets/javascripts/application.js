//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require dropzone
//= require 'china_city/jquery.china_city'


//$(function(){ $(document).foundation(); });



// $ ->
//   $('.datetimepicker').fdatetimepicker({
//     language: 'zh'
//   });


$('.submit-button').on('click', function(){
  $(this).parent().submit();
})