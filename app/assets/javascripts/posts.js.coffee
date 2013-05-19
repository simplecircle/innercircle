$(document).ready ->
  $(".photo-wrapper").click (e)->
      e.preventDefault()
      id = $(this).find(".photo").attr("id")

  # Infinte scroll
  if $('#infinite .pagination').length
    $(window).scroll ->
      url = $('.pagination .next_page').attr('href')
      # The offset needs to be at least over 190px for it to work on the iphone!
      if url && $(window).scrollTop() >= $(document).height() - $(window).height() - 800
        $('.pagination').html('<img src="http://2c97bffff0cd846a6684-2a39f9550587993c48948a67f7aa48eb.r91.cf1.rackcdn.com/assets/ajax-loader-yellow.gif" width="20px" height="20px" />')
        $('.pagination').show()
        $.getScript(url)
  $(window).scroll()
