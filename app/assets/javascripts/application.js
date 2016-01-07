//= require jquery
//= require jquery_ujs
//= require foundation


$(function(){ $(document).foundation(); });



// $ ->
//   $('.datetimepicker').fdatetimepicker({
//     language: 'zh'
//   });


$('.submit-buuton').on('click', function(){
  $(this).parent().submit();
})