$(document).ready ->
  container = $("#masonry")
  unpublishedContainer = $("#masonry.masonry-unpublished")

  containerWidth = container.width()
  unpublishedContainerWidth = unpublishedContainer.width()

  if unpublishedContainer.length == 1
    if $(window).width() > 600
      unpublishedContainer.imagesLoaded ->
        unpublishedContainer.masonry
          columnWidth: (unpublishedContainerWidth ) ->
           unpublishedContainerWidth / 4
    else
      unpublishedContainer.imagesLoaded ->
        unpublishedContainer.masonry
          columnWidth: (unpublishedContainerWidth ) ->
           unpublishedContainerWidth / 2
      $(unpublishedContainer).find("li").css('width', '44%')
  else
    container.width($(window).width()-323)
    $(window).resize ->
      container.width($(window).width()-323)
    container.imagesLoaded ->
      container.masonry
        columnWidth: (containerWidth ) ->
         containerWidth / 2

  # Infinite scroll
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
        existingItems = $("#masonry li")

        success = ->
          container.imagesLoaded ->
            items = $("#masonry li")
            offset = existingItems.length - items.length
            if offset  != -8
              newItems = items.slice(offset)
            else
              newItems = items.slice(-8)
            if $(window).width() < 600
              unpublishedContainer.masonry
                columnWidth: (unpublishedContainerWidth ) ->
                  unpublishedContainerWidth / 2
              $(unpublishedContainer).find("li").css('width', '44%')
            container.masonry( 'appended', newItems );

        $.ajax
          url: url
          dataType: "script"
          success: success
          async: true
