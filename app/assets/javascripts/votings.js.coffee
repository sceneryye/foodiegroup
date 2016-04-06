# vote for selected item
$(document).ready ->
  $('.product-item').on 'click', ->
    if $(this).find('.check-pic').hasClass('hidden')
      $('.product-item').each ->
        item = $(this).find('.check-pic')
        unless item.hasClass('hidden')
          item.addClass('hidden')
      $(this).find('.check-pic').removeClass('hidden')
      img_height = $(this).find('img').css('height')
      img_width = $(this).find('img').css('width')
      check_pic_height = $(this).find('.fa-check').css('height')
      check_pic_width = $(this).find('.fa-check').css('width')
      left = (parseFloat(img_width.replace('px', '')) - parseFloat(check_pic_width.replace('px', ''))) / 2
      top = (parseFloat(img_height.replace('px', '')) - parseFloat(check_pic_height.replace('px', ''))) / 2
      $(this).find('.fa-check').css('left', left)
      $(this).find('.fa-check').css('top', top)
      id = $(this).data('id')
      $('input').val(id)

  $('.vote-submit').on 'click', ->
    post_url = '/voting/vote_for_voting'
    product_id = $('input').val()
    voting_id = $('input').data('voting-id')
    $.ajax {
      url: post_url,
      type: 'post',
      data: {
        product_id: product_id,
        voting_id: voting_id
      },
      success: (e) ->
        if e.msg == 'ok'
          alert('Your vote has been accepted!')
          $('.vote-submit').addClass('hidden')
          $('.votes-counter').removeClass('hidden')
          #display vote bar
          $.each e.data, (key, val) ->
            id = '#' + key
            $(id).text(val)
          all_votes = e.all_votes
          display_bar $('.bar-length'), all_votes
          
        else
          alert e.msg
          console.log e
    }

  # display the vote bar in show page
  all_votes = parseInt $('.votes-counter').data('allvotes')
  if all_votes != 0
    console.log all_votes
    display_bar $('.bar-length'), all_votes

# show-bar method
display_bar = (arr, total) ->
  total_length = (parseInt $('.bar-and-number').css('width')) * 0.9
  console.log total_length
  arr.each ->
    votes = parseInt $(this).parent().find('.votes-number').text()
    console.log votes
    bar_length = votes / total * total_length
    console.log bar_length
    $(this).css('width', bar_length)




