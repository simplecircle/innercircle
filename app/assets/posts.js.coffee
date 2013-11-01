$(".photo-wrapper").live "ajax:before", ->
  if $(this).hasClass 'unpublished'
    $(this).find('.photo-overlay-text').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')
    $(this).addClass('publishing')