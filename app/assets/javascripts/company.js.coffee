threshold = $('.masonry-wrapper').offset().top
navbar = $('.navbar-fixed-top')

scrollHandler = () ->
  if window.scrollY >= 70 && window.innerWidth > 768 #ipad Portrait
    $("#company-info").css({ position: 'fixed', top:20 })
  else
    $("#company-info").css({ position: 'relative'})

  if $(window).width() < 769
    if $(window).scrollTop() > 65
      navbar.addClass 'hidden-nav'
      $('.content-with-nav').css 'margin-top', '40px' if $('body').hasClass 'internal'
    if $(window).scrollTop() - threshold > 0
      navbar.addClass 'scrolling-nav'
      $('.content-with-nav').css 'margin-top', '40px' if $('body').hasClass 'internal'
    else
      navbar.removeClass 'scrolling-nav hidden-nav'
      $('.content-with-nav').css 'margin-top', '0' if $('body').hasClass 'internal'


$(window).scroll scrollHandler
scrollHandler()