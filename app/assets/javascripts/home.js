
//倒计时
$(document).ready(function(){
  countdown($('.groupbuy-list'));
  countdown($('.event-list'));
});


function countdown(obj) {

obj.each(function(){
  var endTime = $(this).data('endtime');
  var day = $(this).data('day');
  var that = $(this);
  window.setInterval(function(){
    var EndTime= endTime;
    var NowTime = new Date();
    var t =EndTime * 1000 - NowTime.getTime();
    if(t < 0) {
      //console.log(t);
      var over = obj.parent().data('over');
      $(that).find('.countdown').text(over);
      return;
    }

    var d=Math.floor(t/1000/60/60/24);
    var h=Math.ceil(t/1000/60/60%24);
    var m=Math.floor(t/1000/60%60);
    var s=Math.floor(t/1000%60);

    if(m < 10) {
      m = '0' + m;
    }
    if(s< 10) {
      s = '0' + s;
    }
    if(h< 10) {
      h = '0' + h;
    }
    if(day == 'Day') {
      days = 'D';
      hours = 'H';
    }
    else {
      days = '天';
      hours = '小时';
    }

    that.find('.countdown-day').text(d + days);
    that.find('.countdown-hour').text(h + hours);
    //that.find('.countdown-minute').text(m + ':');
    //that.find('.countdown-second').text(s);
  }, 1000)

  
  
  //setInterval(getRTime,1000);
});
}