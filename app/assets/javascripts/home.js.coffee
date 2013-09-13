# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

if $('#home').length > 0
  feedFrame = $('.js-homepage-screenshots__feed__frame') 
  scrollableFeed = $('.js-homepage-screenshots__feed__scrollable-div')

  homepageScreenResizeHandler = ->
    scrollableFeed.css('height', feedFrame.width()*0.95)

  $(window).on 'resize.homepage', -> homepageScreenResizeHandler()

  homepageScreenResizeHandler()