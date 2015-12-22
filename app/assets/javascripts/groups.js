//$('.group-detail').unbind('click');
//$('.info').undind('click');
//为了防止点击一次出现2次click效果，用了时间戳来阻止，但原因不明。
var event_time = 0;
$('.modify').on('click', function(){
  var now = new Date();
  if(now - event_time < 100) {
    console.log(now - event_time);
    return;
  }
  var that = $(this);
  var parent_element = that.parent();
  parent_element.find('.modify').toggle();
  parent_element.find('.group-value').toggle();
  parent_element.find('.edit-form').toggle();
  parent_element.find('.check').toggle();
  parent_element.find('.remove').toggle();
  console.log(now - event_time);
  event_time = now;
});

$('.group-detail').on('click', '.remove', function(){
  var now = new Date();
  if(now - event_time < 100) {
    console.log(now - event_time);
    return;
  }
  var that = $(this);
  var parent_element = that.parent();
  parent_element.find('.modify').toggle();
  parent_element.find('.group-value').toggle();
  parent_element.find('.edit-form').toggle();
  parent_element.find('.check').toggle();
  parent_element.find('.remove').toggle();
  event_time = now;
});

$('.check').on('click', function(){
  var now = new Date();
  if(now - event_time < 100) {
    console.log(now - event_time);
    return;
  }
  var name = '';
  var group_desc = '';
  var that = $(this);
  var parent_element = that.parent();
  var content = '';
  if(parent_element.find('input').val().replace(/[\s]/g, '').length < 4) {
    parent_element.find('.error-message').text('字数不能少于4！')
  }
  else {
    content = parent_element.find('input').val();
    var id = $('.group-detail').data('id');
    var url = '/groups/' + id;
    if(parent_element.attr('class').split(' ')[0] == 'group-name'){

      name = $("input[name='name']").val();

      group_desc = $('.group-intro').find('.group-value').text();
    }
    else {
      name = $('.group-name').find('.group-value').text();
      group_desc = $("input[name='group_desc']").val();
    }
    event_time = now;

    $.ajax({
      url: url,
      type: 'patch',
      data: {
        name: name,
        group_desc: group_desc
      },
      success: function(e) {
        if(e == 'success') {
          alert('更新成功！');
          parent_element.find('.modify').toggle();
          parent_element.find('.group-value').toggle();
          parent_element.find('.edit-form').toggle();
          parent_element.find('.check').toggle();
          parent_element.find('.remove').toggle();
          parent_element.find('.group-value').text(content);
        };
      }
    });
  }
  
});
