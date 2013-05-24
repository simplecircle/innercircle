$(document).ready ->
  # handler = null
  # options =
  #   itemWidth: 200
  #   autoResize: true
  #   container: $('#collection')
  #   offset: 5
  #   flexibleWidth: 250

  # handler = $('#collection li');
  # handler.wookmark(options);


  $(".photo-wrapper").live "ajax:before", ->
    $(this).find('.cta').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')


