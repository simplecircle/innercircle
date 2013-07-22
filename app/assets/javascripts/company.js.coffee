masonryWrapper = $('.masonry-wrapper')

if masonryWrapper.length > 0
  threshold = $('.masonry-wrapper').offset().top
  navbar = $('.navbar-fixed-top')
  contentWithNav = $('.content-with-nav')
  referrer = if $('body').hasClass 'internal' then 'internal' else 'external'
  companyInfo = $("#company-info")

  scrollHandler = () ->
    if window.scrollY >= 70 && window.innerWidth > 768 #ipad Portrait
      companyInfo.css({ position: 'fixed', top:20 })
    else
      companyInfo.css({ position: 'relative'})

    if $(window).width() < 769
      if $(window).scrollTop() > 65
        navbar.addClass 'hidden-nav'
        contentWithNav.css 'margin-top', '40px' if referrer == 'internal'
      if $(window).scrollTop() - threshold > 0
        navbar.addClass 'scrolling-nav'
        contentWithNav.css 'margin-top', '40px' if referrer == 'internal'
      else
        navbar.removeClass 'scrolling-nav hidden-nav'
        contentWithNav.css 'margin-top', '0' if referrer == 'internal'


  $(window).scroll scrollHandler
  scrollHandler()