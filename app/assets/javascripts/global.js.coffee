$(document).ready ->

  container = $("#masonry")
  containerWidth = container.width()
  unpublishedContainer = $("#masonry.masonry-unpublished")
  unpublishedContainerWidth = unpublishedContainer.width()
  mode = "unpublished" if unpublishedContainer.length == 1

  setHeight = (columnCount, containerWidth, items) ->
    $.each items, ->
      width = (containerWidth/columnCount)
      if mode == "unpublished"
        # Target img instead of li so info bar will be correctly placed
        $(this).find('.photo img').height(Math.round(width * $(this).data("aspect-ratio")))
      else
        $(this).find('.photo img').height(Math.round(width * $(this).data("aspect-ratio")))

  if mode == "unpublished"
    items = $(unpublishedContainer).find("li")
    columnCount = if window.innerWidth > 768 then 4 else 2
    setHeight(columnCount, unpublishedContainerWidth, items)
    unpublishedContainer.masonry
      columnWidth: (unpublishedContainerWidth ) ->
       unpublishedContainerWidth/columnCount
    if window.innerWidth <= 768 then items.css('width', '44%')
    items.fadeIn("fast")
  else
    columnCount = if window.innerWidth > 570 then 2 else 1
    items = $(container).find("li")
    initPublished = ->
      setHeight(columnCount, container.width(), items)
      container.masonry
        columnWidth: ->
         container.width()/columnCount
    initPublished()
    items.fadeIn("fast")

    $(window).resize ->
      initPublished()



  # Infinite scroll
  if $('#infinite .pagination').length
    $(window).scroll ->
      if window.scrollY >= 70 && window.innerWidth > 768 #ipad Portrait
        $("#company-info").css({ position: 'fixed', top:20 })
      else
        $("#company-info").css({ position: 'relative'})

      url = $('.pagination .next_page').attr('href')
      # The offset needs to be at least over 190px for it to work on the iphone!
      if url && window.scrollY >= $(document).height() - window.innerHeight - 500
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
            if window.innerWidth < 600
              # Two columns for phones please
              unpublishedContainer.masonry
                columnWidth: (unpublishedContainerWidth ) ->
                  unpublishedContainerWidth / 2
              $(unpublishedContainer).find("li").css('width', '44%')
              setHeight(2, unpublishedContainerWidth, newItems)
            else
              setHeight(4, unpublishedContainerWidth, newItems)
            unpublishedContainer.masonry( 'appended', newItems);
          else
            setHeight(2, containerWidth, newItems)
            container.masonry( 'appended', newItems );
          newItems.fadeIn("fast")

        $.ajax
          url: url
          dataType: "script"
          success: success
          async: true