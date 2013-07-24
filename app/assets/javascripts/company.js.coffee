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
      if $(window).scrollTop() - threshold > 0
        navbar.addClass 'nav-scrolling'
      else
        navbar.removeClass 'nav-scrolling'


  $(window).scroll scrollHandler
  scrollHandler()