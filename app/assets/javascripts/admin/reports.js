//= require jquery
//= require jquery_ujs

$(document).ready(function(){

//判断值是否为空

function checkNull(obj_value){
    var name = obj_value.replace(/[\s]/g,"");//把所有空格去掉
    if(name.length==0){
      return true;
    }
  }

// click to confirm shiped

$('.participant-ship-confirm').on('click', function(){
  var id = $(this).data('id');
  var url = $(this).data('url');
  var that = $(this);
  
  swal({
    title: "确认发货",
    text: '请输入运单号',
    type: 'input',
    showCancelButton: true,
    closeOnConfirm: false,
    closeOnCancel: true,
    animation: "slide-from-top"
  }, function(inputValue){
    if (inputValue === false) return false;
    console.log("You wrote", inputValue);
    var trackingNumber = inputValue;
    if(trackingNumber.replace(/\s/g, '').length < 13) {
      swal.showInputError('正确的运单号为13位数字！');
      return false;
      return;
    }
    $.ajax({
      url: url,
      type: 'post',
      data: {
        id: id,
        tracking_number: trackingNumber
      },
      success: function(e) {
        if(e == 'success') {
          that.find('.ship-confirm').remove();
          that.text(trackingNumber);
          that.unbind('click');
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
  var groupbuy_id = $(this).data('id');

  var url = $(this).data('url');//'/groupbuys/' + groupbuy_id;

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
      from: 'admin_groupbuy_list'
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
var navpath_width = $('.navpath').width();
var off_right = navpath_width * 0.1 + 10 + 'px';
$('.tags_list .add-tag').css({"margin-right": off_right});
function disableInput(){
  $('.tags_list .table-content').find('input').each(function(){
    $(this).attr('disabled', true);
  });
}
disableInput();
//--编辑
$('.tags_list td').on('click', '.edit', function(){
  var that = $(this);
  var input_objs = that.parent().parent().find('input');
  input_objs.each(function(){
    $(this).attr('disabled', false);
  });
  that.parent().find('.edit').addClass('hidden');
  that.parent().find('.delete').addClass('hidden');
  that.parent().find('.cancel').removeClass('hidden');
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
        that.parent().find('.delete').removeClass('hidden');
        that.parent().find('.edit').removeClass('hidden');
        that.parent().find('.cancel').addClass('hidden');
        disableInput();
      };
    }
  });
});

$('.tags_list .table-content').on('click', '.cancel', function(){
  var that = $(this);
  var input_objs = that.parent().parent().find('input');
  input_objs.each(function(){
    $(this).attr('disabled', true);
    var data_value = $(this).data('value');
    $(this).val(data_value);
  });
  that.parent().find('.confirm').addClass('hidden');
  that.parent().find('.delete').removeClass('hidden');
  that.parent().find('.edit').removeClass('hidden');
  that.parent().find('.cancel').addClass('hidden');
});

//--删除
$('.tags_list').on('click', '.table-content .delete', function(){
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


$('.tags_list').on('click', '.shown-row .cancel', function(){
  $(this).parent().parent().remove();
})



//--添加
$('.tags_list').on('click', '.add-tag', function(){
  var hidden_row = $('<tr class="shown-row">' + $('.tags_list .hidden-row').html() + '</tr>');
  hidden_row.insertAfter('.tags_list .table-title');
});

$('.tags_list ').on('click', '.shown-row .confirm', function(){

  var that = $(this);
  var parent_obj = that.parent().parent();
  var name = parent_obj.find("input[name='name']").val();
  var url = parent_obj.find("input[name='url']").val();
  var locale = parent_obj.find("input[name='locale']").val();
  var post_url = '/tags';
  if(checkNull(name) || checkNull(url) || checkNull(locale)) {
    swal("失败！", "参数不能为空！", "error");
    return;
  }
  $.ajax({
    url: post_url,
    type: 'post',
    data: {
      name: name,
      url: url,
      locale: locale,
    },
    success: function(e) {
      if(e != 'fail') {
        swal('成功！', '您已添加了一条新的数据。', 'success');
        that.parent().find('.confirm').addClass('hidden');
        that.parent().find('.edit').removeClass('hidden');
        that.parent().find('.delete').removeClass('hidden');
        that.parent().find('.cancel').addClass('hidden');
        $('.tags_list .shown-row').addClass('table-content');
        
        $('.tags_list .shown-row').find('.id').text(e);
        $('.tags_list .shown-row').removeClass('shown-row');
        disableInput();
        return;
      };
    }
  });
});

//编辑团购标题
$('.groupbuys-list').on('click', '.edit-title', function(){
  var that = $(this);
  var id = that.data('id');
  var title = that.data('title');
  var url = '/groupbuys/' + id;
  swal({
    title: "修改标题",
    text: '请输入你想要修改的标题',
    type: 'input',
    showCancelButton: true,
    closeOnConfirm: false,
    closeOnCancel: true,
    animation: "slide-from-top"
  }, function(inputValue){
    if (inputValue === false) return false;
    console.log("You wrote", inputValue);
    var new_title = inputValue;
    if(new_title.replace(/\s/g, '').length < 4) {
      swal.showInputError('字数不能少于4！');
      return false;
      return;
    }
    
    swal({
      title: "选择语言",
      text: '修改中文标题请输入zh，修改英文标题请输入en',
      type: 'input',
      showCancelButton: true,
      closeOnConfirm: false,
      closeOnCancel: true,
      animation: "slide-from-top"
    }, function(inputValue){
      if (inputValue === false) return false;
      console.log("You wrote", inputValue);
      var language = inputValue;
      if(language.replace(/\s/g, '') != 'zh' && language.replace(/\s/g, '') != 'en') {
        swal.showInputError('请输入zh或者en');
        return false;
        return;
      }
      $.ajax({
        url: url,
        type: 'patch',
        data: {
          id: id,
          title: new_title,
          from: 'admin_edit_title',
          language: language
        },
        success: function(e) {
          if(e == 'success') {
            that.parent().parent().find('.groupbuy-title').text(new_title.slice(0,10));
            swal('成功!', '修改成功！', 'success');
          }
          else {
            swal('失败!', '提交失败', 'error');
          }
        }
      });
    });
});
});

//编辑话题推荐值

$('.topic-recommend').on('click', function(){

  var that = $(this);
  var nums = $(this).val();
  var topic_id = $(this).data('id');
  var url = '/topics/' + topic_id;
  var nums_value = $(this).data('value');
  swal({
    title: "修改推荐值",
    text: '请输入你想要修改的推荐值',
    type: 'input',
    showCancelButton: true,
    closeOnConfirm: false,
    closeOnCancel: true,
    animation: "slide-from-top"
  }, function(inputValue){
    if (inputValue === false) return false;
    console.log("You wrote", inputValue);
    var new_recommend = inputValue;
    if(isNaN(new_recommend)) {
      swal.showInputError('必须输入数字！');
      return false;
      return;
    }
    $.ajax({
      url: url,
      type: 'patch',
      data: {
        id: topic_id,
        recommend: new_recommend,
        from: 'admin_edit_recommend'
      },
      success: function(e) {
        if(e == 'success') {
          that.parent().parent().find('.topic-recommend').val(new_recommend);
          swal('成功!', '修改成功！', 'success');
        }
        else {
          swal('失败!', '提交失败', 'error');
        }
      }
    });
  });
});

})
