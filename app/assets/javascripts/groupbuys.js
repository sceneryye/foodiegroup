$(document).ready(function(){
  $('.new-groupbuy').find('input').each(function(){
    if(($(this).val()=='0' || $(this).val()=='0.0') && location.pathname.split('/')[2] == 'new'){
      $(this).val('');
    }
  });
});