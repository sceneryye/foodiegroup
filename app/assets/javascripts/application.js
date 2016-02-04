//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require dropzone


//$(function(){ $(document).foundation(); });



// $ ->
//   $('.datetimepicker').fdatetimepicker({
//     language: 'zh'
//   });


$('.submit-button').on('click', function(){
  $(this).parent().submit();
})

function get_freightage(){
	 var url = '/foodiegroup/cal_freightage';
    var num =  $('.participant-number').val();
    var groupbuy_id = $('.participant-number').data('id');
    if(num > 0) {
      $.ajax({
        url: url,
        type: 'post',
        data: {
          num: num,
          groupbuy_id: groupbuy_id
        },
        success: function(e) {
          var fee = e.freightage;
          $('.freightage-fee').text(fee);
          $('.total-fee').text(e.total_price);
        }
      });
    }
}

//----------------提示分享----------------------//

$(document).ready(function(){
  $('.share-button').on('click', function(){
    var msg = $(this).data('msg');
    alert(msg);
  })
})

//--------------为达到最低团购数量不能提交订单---------------//
$(document).ready(function(){
  $('.list_button').on('submit', '.new_participant', function(e){
    var num = parseFloat($('.participant-number').data('minimal'));
    var other_num = $('#participant_quantity').val();
    console.log('num=' + num);
    console.log('other_num=' + other_num);
    if(other_num < num) {
      e.preventDefault();
      return false;
    }
  });
});

//-------------中英文切换--------------//
function change_locale(obj){
    var locale = $(obj).data('locale');
    url = 'http://' + location.host + location.pathname + '?locale=' + locale;
    console.log(url);
    location.href = url;
  };

