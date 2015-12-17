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
    closeOnConfirm: false 
  },
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

// 活动的首页推荐

$('.recommend-number').on('change', function(){
  var that = $(this);
  var nums = $(this).val();
  var event_id = $(this).data('id');
  var url = '/events/' + event_id;
  var nums_value = $(this).data('value');
  if(nums == '' || nums == undefined || isNaN(nums) == true) {
    $(this).val(nums_value);
    swal("失败！", "只能输入整数", "error")
    return;
  }
  $.ajax({
    url: url,
    type: "patch",
    data: {
      recommend: nums,
      from: 'admin_event_list'
    },
    success: function(e){
      if(e == 'success') {
        swal("修改成功！", "现在该活动的推荐值为" + parseInt(nums), "success");
        that.val(parseInt(nums));
      }
    }
  });
});

// 标签云的添加编辑删除
$('.tags_list .table-content').find('input').each(function(){
  $(this).attr('disabled', true);
});

$('.tags_list td').on('click', '.edit', function(){
  var that = $(this);
  var input_objs = that.parent().parent().find('input');
  input_objs.each(function(){
    $(this).attr('disabled', false);
  });
  that.parent().find('.edit').addClass('hidden');
  that.parent().find('.confirm').removeClass('hidden');
})

$('.tags_list .table-content').on('click', '.confirm', function(){
  var that = $(this);
  var parent_obj = that.parent().parent();
  var name = parent_obj.find("input[name='name']").val();
  var url = parent_obj.find("input[name='url']").val();
  var locale = parent_obj.find("input[name='locale']").val();
  var id = parent_obj.find('.id').text();
  var post_url = '/tags/' + id;
  $.ajax({
    url: post_url,
    type: 'patch',
    data: {
      id: id,
      name: name,
      url: url,
      locale: locale
    },
    success: function(e) {
      if(e == 'success') {
        swal('成功！', '您的数据已经更新。', 'success');
        that.parent().find('.confirm').addClass('hidden');
        that.parent().find('.edit').removeClass('hidden');
      };
    }
  });
});

$('.tags_list td').on('click', '.delete', function(){
  var that = $(this);
  var parent_obj = that.parent().parent();
  var id = parent_obj.find('.id').text();
  var post_url = '/tags/' + id;
  swal({   
    title: "删除确认",
    text: "点击“确定”将会删除该标签！",
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: "确定",
    closeOnConfirm: false 
  },
  function(){ 
    $.ajax({
      url: post_url,
      type: 'delete',
      data: {
        id: id,
      },
      success: function(e) {
        if(e == 'success') {
          swal('成功！', '您的数据已经删除。', 'success');
          parent_obj.remove();
        };
      }
    });
  });
});

$('.tags_list').on('click', '.add-tag', function(){
  var hidden_row = $('.tags_list .hidden-row');
  hidden_row.removeClass('hidden');

    
});
