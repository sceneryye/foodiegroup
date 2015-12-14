// click to confirm shiped

$('.participant-ship-confirm').on('click', function(){
  var id = $(this).data('id');
  var url = $(this).data('url');
  var that = $(this);
  swal({   
    title: "确认完成发货？",
    text: "点击“确定”将会完成发货！",
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: "确定",
    closeOnConfirm: false },
    function(){ 
      $.ajax({
        url: url,
        type: 'post',
        data: {
          id: id,
        },
        success: function(e) {
          if(e == 'success') {
            that.find('.ship-confirm').remove();
            var ship = "#participant-" + id;
            $(ship).text("已发货");
            swal("发货已完成！", "该团购已完成发货，等待对方收货。", "success");
          };
        }
      });
    });
  
});
