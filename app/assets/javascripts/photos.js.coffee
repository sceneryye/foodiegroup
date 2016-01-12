# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
    $('#photo_image').fileupload
        dataType: 'json'
        done: (e, data)->
            $.each data.result.files, (index, file) ->
                list = $('#preview > .hide').clone()
                list.find('> a').attr('href', file.url)
                list.find('img').attr('src', file.small_url)
                list.find('h4').text(file.name)
                list.find('.media-body a').attr('data-method', file.delete_type).attr('href', file.delete_url)
                .attr('data-remote', true)
                list.removeClass('hide').appendTo('#preview');

        progressall: (e, data)->
            progress = parseInt(data.loaded / data.total * 100, 10)
            $('.progress .progress-bar').css('width', "#{progress}%")

    $(document).bind 'dragover': (e) ->
        dropZone = $('#dropzone'); timeout = window.dropZoneTimeout

        if(!timeout)
            dropZone.addClass('in')
        else
            clearTimeout(timeout)

        found = false; node = e.target;
        loop
            if( node is dropZone[0])
                found = true
                break;
            node = node.parentNode
            break if(node isnt null)
        if(found)
            dropZone.addClass('hover')
        else
            dropZone.removeClass('hover')

        window.dropZoneTimeout =
            setTimeout ->
                window.dropZoneTimeout = null;
                dropZone.removeClass('in hover');
            , 100

    $(document).on 'click', 'a.delete', ->
        $(this).parents('.media').remove()