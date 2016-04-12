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