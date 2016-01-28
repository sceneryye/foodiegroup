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
