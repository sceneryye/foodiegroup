# show the thumbnail when choose a picture
$('.document').ready ->
  $('#wishlist_picture').on 'change', ->
    file = $(this)[0]
    pic = $('.create-wishlist').find('img')[0]
    if window.FileReader
      oFReader = new FileReader()
      oFReader.readAsDataURL(file.files[0])
      oFReader.onload = (oFREvent) ->
        pic.src = oFREvent.target.result


  # publish a  wishlist
  $('.downpayment-value').on 'change', ->
    amount = $(this).val()
    if !isNaN(amount) && amount.length > 0
      $(this).parent().parent().find('.publish-wishlist').removeClass('disabled')

  $('.publish-wishlist').on 'click', ->
    if !$(this).hasClass('disabled')
      amount = $(this).parent().parent().find('.downpayment-value').val()
      url = $('.wishlists-management').data('url')
      id = $(this).data('id')
      data = {down_payment: amount, online: true, id: id}
      $.post url, data, (e) =>
        alert(e.notice)
        $(this).parent().parent().parent().remove()

  # go to the downpayment url
  $('.downpayment-pay-link').on 'click', ->
    mobile = $(this).data('mobile').toString()
    console.log mobile.length
    user_id = $(this).data('userid')
    url = $(this).data('url')
    if mobile.length == 11
      location.href = url
    else
      $('.set-mobile-before-downpayment').removeClass('hidden')
      $('.submit-mobile').on 'click', ->
        mobile_value = $('.set-mobile').find('input').val().toString()
        console.log mobile_value
        if mobile_value.length == 11
          post_url = $(this).data('url')
          $.post post_url, {mobile: mobile_value, user_id: user_id}, (e) ->
            if e.msg == 'ok'
              location.href = url
            else
              $('.set-mobile').find('.errmsg').text(e.msg)
        else
          $('.set-mobile').find('.errmsg').text('Please enter the correct mobile!')