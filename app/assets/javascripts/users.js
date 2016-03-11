var event_time = 0;

$('.show-groups').on('click', function(){
  var now = new Date();
  if(now - event_time < 100) {
    
    return;
  }
  event_time = now;
  console.log(now - event_time);
  $('.group-list').toggle(1000);
  });
