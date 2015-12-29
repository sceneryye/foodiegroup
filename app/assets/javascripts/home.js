//= require foundation-datetimepicker

//= require ckeditor/init

//倒计时

$('.groupbuy-list').each(function(){
  var endTime = $(this).data('endtime');
  var day = $(this).data('day');
  var that = $(this);
  window.setInterval(function(){
    var EndTime= endTime;
    var NowTime = new Date();
    var t =EndTime * 1000 - NowTime.getTime();
    if(t < 0) {
      console.log(t);
      var over = $('.events-index').data('over');
      $(that).find('.countdown').text(over);
      return;
    }

    var d=Math.floor(t/1000/60/60/24);
    var h=Math.floor(t/1000/60/60%24);
    var m=Math.floor(t/1000/60%60);
    var s=Math.floor(t/1000%60);

    that.find('.countdown-day').text(d + day);
    that.find('.countdown-hour').text(h + ':');
    that.find('.countdown-minute').text(m + ':');
    that.find('.countdown-second').text(s);
  }, 1000)

  
  
  //setInterval(getRTime,1000);
});