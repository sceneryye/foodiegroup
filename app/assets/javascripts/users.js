//= require jquery
//= require jquery_ujs
//= require foundation
//= require foundation-datetimepicker
//= require ckeditor/init
$('.show-group').unbind('click');
$('.show-group').on('click', function(){
  $('.group-list').toggle(1000);
  });
