$(document).ready ->
  handler = null
  options =
    autoResize: true
    container: $('#collection')
    offset: 20

  # handler = $('#collection li');
  # handler.wookmark(options);
  # handler.trigger('refreshWookmark');


  $(".photo-wrapper").live "ajax:before", ->
    $(this).find('.cta').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')


  # Infinte scroll
  if $('#infinite .pagination').length
    $(window).scroll ->
      url = $('.pagination .next_page').attr('href')
      # The offset needs to be at least over 190px for it to work on the iphone!
      if url && $(window).scrollTop() >= $(document).height() - $(window).height() - 600
        $('.pagination').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')
        $('.pagination').show()
        $.getScript(url)
  # $(window).scroll()
