#= require foundation-datepicker.min


# show the thumbnail when choose a picture
$('.document').ready ->
  $('#vote_product_picture').on 'change', ->
    file = $(this)[0]
    pic = $(this).parent().parent().find('img')[0]
    if window.FileReader
      oFReader = new FileReader()
      oFReader.readAsDataURL(file.files[0])
      oFReader.onload = (oFREvent) ->
        pic.src = oFREvent.target.result


# create voting
$('.document').ready ->
  $('.fdatepicker').fdatepicker {
    language: 'zh-CN',
    format: 'yyyy-mm-dd hh:ii',
    disableDblClickSelection: true,
    pickTime: true
  }

  $('.create-voting').on 'click', ->
    $(window).scrollTop(0)
    ids = []
    $('[type="checkbox"]').each ->
      ids.push $(this).data('id') if $(this).is(':checked')
    ids = ids.join(',')
    console.log ids
    $('.background-layer').removeClass('hidden')
    $('.datetime-dash').removeClass('hidden')
    $('.voting-name').on 'change', ->
      end_time = $('.fdatepicker').val()
      name = $('.voting-name').val()
      return if end_time.length < 1 || name.length < 1
      $('.submit-voting').removeClass('hidden')
      $('.submit-voting').on 'click', ->
        post_url = "/votings"
        $.ajax {
          url: post_url,
          type: 'post',
          data: {
            ids: ids,
            end_time: end_time,
            name: name
          },
          success: (e) ->
            if e.msg == 'ok'
              location.pathname = '/votings/' + e.id
            else
              alert e.msg
        }