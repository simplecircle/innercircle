subscribeButtonBody = $('.subscribe-button-body')
if $('#company-info').length > 0
  companySubdomain = $('#company-info').data().companySubdomain
else
  companySubdomain = undefined

if subscribeButtonBody.length > 0
  threshold = subscribeButtonBody.offset().top
  navbar = $('.navbar-fixed-top')
  companyInfo = $("#company-info")

  scrollHandler = () ->
    if window.scrollY >= 70 && window.innerWidth > 768 #ipad Portrait
      companyInfo.css({ position: 'fixed', top:20 })
    else
      companyInfo.css({ position: 'relative', top:0})

    if $(window).width() < 769
      if $(window).scrollTop() - threshold > 0
        navbar.addClass 'nav-scrolling'
      else
        navbar.removeClass 'nav-scrolling'

  $(window).scroll scrollHandler
  $(window).resize scrollHandler
  scrollHandler()

$('.js-btn-subscribe').on 'click', (e)->
  _gaq.push(['_trackEvent', 'Companies', 'Go To Signup Form', companySubdomain])

$('.js-btn-see-company-jobs').on 'click', (e)->
  _gaq.push(['_trackEvent', 'Companies', 'See Jobs', companySubdomain]);