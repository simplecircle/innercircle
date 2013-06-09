$(document).ready ->

  container = $("#masonry")
  containerWidth = container.width()
  unpublishedContainer = $("#masonry.masonry-unpublished")
  unpublishedContainerWidth = unpublishedContainer.width()
  mode = "unpublished" if unpublishedContainer.length == 1

  setHeight = (columnCount, containerWidth, items) ->
    $.each items, ->
      width = containerWidth/columnCount
      $(this).height(width * $(this).data("aspect-ratio"))

  if mode == "unpublished"
    items = $(unpublishedContainer).find("li")
    if $(window).width() > 600
      columnCount = 4
      unpublishedContainer.masonry
        columnWidth: (unpublishedContainerWidth ) ->
         unpublishedContainerWidth/columnCount
      setHeight(columnCount, unpublishedContainerWidth, items)
      items.fadeIn("fast")
    else
      # Two columns for phones please
      columnCount = 2
      unpublishedContainer.masonry
        columnWidth: (unpublishedContainerWidth ) ->
         unpublishedContainerWidth/columnCount
      setHeight(columnCount, unpublishedContainerWidth, items)
      items.css('width', '44%')
      items.fadeIn("fast")
  else
    # container.width($(window).width()-323)
    # $(window).resize ->
      # container.width($(window).width()-323)
    columnCount = 2
    container.masonry
      columnWidth: (containerWidth ) ->
       containerWidth/columnCount
    items = $(container).find("li")
    setHeight(columnCount, containerWidth, items)
    items.fadeIn("fast")



  # Infinite scroll
  if $('#infinite .pagination').length
    $(window).scroll ->
      if $(window).scrollTop() >= 70
        $("#company-info").css({ position: 'fixed', top:20 })
      else
        $("#company-info").css({ position: 'relative'})

      url = $('.pagination .next_page').attr('href')
      # The offset needs to be at least over 190px for it to work on the iphone!
      if url && $(window).scrollTop() >= $(document).height() - $(window).height() - 500
        $('.pagination').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')
        $('.pagination').show()
        existingItems = $("#masonry li")

        success = ->
          items = $("#masonry li")
          offset = existingItems.length - items.length
          if offset  != -8
            newItems = items.slice(offset)
          else
            newItems = items.slice(-8)

          if mode == "unpublished"
            if $(window).width() < 600
              # Two columns for phones please
              unpublishedContainer.masonry
                columnWidth: (unpublishedContainerWidth ) ->
                  unpublishedContainerWidth / 2
              $(unpublishedContainer).find("li").css('width', '44%')

            setHeight(4, unpublishedContainerWidth, newItems)
            unpublishedContainer.masonry( 'appended', newItems );
          else
            setHeight(2, containerWidth, newItems)
            container.masonry( 'appended', newItems );
          newItems.fadeIn("fast")

        $.ajax
          url: url
          dataType: "script"
          success: success
          async: true
