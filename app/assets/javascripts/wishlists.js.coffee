# show the thumbnail when choose a picture
$('.document').ready ->
  $('#wishlist_picture').on 'change', ->
    file = $(this)[0]
    pic = $(this).parent().parent().find('img')[0]
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