//= require foundation-datetimepicker

//= require ckeditor/init


$(document).ready(function(){
  $('.new-groupbuy').find('input').each(function(){
    if(($(this).val()=='0' || $(this).val()=='0.0') && location.pathname.split('/')[2] == 'new'){
      $(this).val('');
    }
  });
});

$('.new_participant').on('change', '.goods-weight', function(){
  var that = $(this);
  var nums = that.val();
  if(nums == '' || nums == undefined || isNaN(nums) == true || nums < 1) {
    $(this).val('');
    alert("只能输入正整数");
    return;
  }
})