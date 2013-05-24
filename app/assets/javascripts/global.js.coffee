$(document).ready ->

  # Infinte scroll
  if $('#infinite .pagination').length
    $(window).scroll ->
      url = $('.pagination .next_page').attr('href')
      # The offset needs to be at least over 190px for it to work on the iphone!
      if url && $(window).scrollTop() >= $(document).height() - $(window).height() - 700
        $('.pagination').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')
        $('.pagination').show()

        success = ->
          handler = null
          if url.indexOf("posts") == 1
            options =
              itemWidth: 250 # Optional min width of a grid item
              autoResize: true # This will auto-update the layout when the browser window is resized.
              container: $("#collection") # Optional, used for some extra CSS styling
              offset: 13 # Optional, the distance between grid items
              flexibleWidth: 300 # Optional, the maximum width of a grid item
          else
            options =
              itemWidth: 450
              autoResize: true
              container: $("#collection")
              offset: 13
              flexibleWidth: 550

          handler = $("#collection li")
          newItems = handler.slice(-8)
          handler.wookmark options

        $.ajax
          url: url
          dataType: "script"
          success: success
          async: true
  $(window).scroll()
