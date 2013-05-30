$(document).ready ->

  container = $("#masonry-published")
  container.width($(window).width()-323)
  $(window).resize ->
    container.width($(window).width()-323)
  containerWidth  = container.width()

  container.imagesLoaded ->
    container.masonry
      columnWidth: (containerWidth ) ->
       containerWidth / 2

  # Infinte scroll
  if $('#infinite .pagination').length
    $(window).scroll ->
      if $(window).scrollTop() >= 70
        $("#company-info").css({ position: 'fixed', top: 0 })
      else
        $("#company-info").css({ position: 'relative'})

      url = $('.pagination .next_page').attr('href')
      # The offset needs to be at least over 190px for it to work on the iphone!
      if url && $(window).scrollTop() >= $(document).height() - $(window).height() - 300
        $('.pagination').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')
        $('.pagination').show()
        existingItems = $("#masonry-published li")

        success = ->
          container.imagesLoaded ->
            items = $("#masonry-published li")
            offset = existingItems.length - items.length
            if offset  != -8
              newItems = items.slice(offset)
            else
              newItems = items.slice(-8)
            container.masonry( 'appended', newItems );

        $.ajax
          url: url
          dataType: "script"
          success: success
          async: true
