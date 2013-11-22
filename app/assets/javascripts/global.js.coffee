$(document).ready ->
  container = $("#masonry")
  containerWidth = container.width()
  unpublishedContainer = $("#masonry.masonry-unpublished")
  unpublishedContainerWidth = unpublishedContainer.width()
  mode = "unpublished" if unpublishedContainer.length == 1

  setHeight = (columnCount, containerWidth, items) ->
    $.each items, ->
      # 29 makes up for the faux gutter
      width = (containerWidth/columnCount)-15
      height = Math.round(width * $(this).data("aspect-ratio"))
      if mode == "unpublished"
        # Both image and parent li need their height set to work in FF
        $(this).find('.photo-img').height(Math.round(width * $(this).data("aspect-ratio")))
        $(this).height(Math.round(width * $(this).data("aspect-ratio"))+70)
      else
        # Both image and parent li need their height set to work in FF
        $(this).find('.photo-img').attr('height', height)
        $(this).css('min-height', height)

  if mode == "unpublished"
    items = $(unpublishedContainer).find("li")
    columnCount = if window.innerWidth > 570 then 4 else 2
    setHeight(columnCount, unpublishedContainerWidth, items)
    unpublishedContainer.masonry
      columnWidth: (unpublishedContainerWidth ) ->
       unpublishedContainerWidth/columnCount
    if window.innerWidth <= 570 then items.css('width', '44%')
    items.fadeIn("fast")
  else
    columnCount = 2 
    items = $(container).find("li")
    initPublished = ->
      setHeight(columnCount, container.width(), items)
      container.masonry
        columnWidth: ->
          container.width()/columnCount
    initPublished()
    items.show()

    $(window).resize ->
      initPublished()



  # Infinite scroll
  loading = false
  queryOffsetQuantity = 14
  queryOffset = queryOffsetQuantity 
  $(window).scroll ->
    scrollY = if window.pageYOffset != undefined then window.pageYOffset else (document.documentElement || document.body.parentNode || document.body).scrollTop
    # The offset needs to be at least over 190px for it to work on the iphone!
    # Dont page if .loader is not present
    if (scrollY >= $(document).height() - window.innerHeight - 800) and $('.loader').length
      existingItems = $("#masonry li")
      

      onComplete = ->
        # This block only gets ran if its for a Masonry page
        items = $("#masonry li")
        if items.length
          offset = existingItems.length - items.length
          console.log offset
          if offset  != -14
            newItems = items.slice(offset)
          else
            newItems = items.slice(-14)

          if mode == "unpublished"
            if window.innerWidth < 600
              # Two columns for phones please
              unpublishedContainer.masonry
                columnWidth: (unpublishedContainerWidth ) ->
                  unpublishedContainerWidth / 2
              $(unpublishedContainer).find("li").css('width', '44%')
              setHeight(columnCount, unpublishedContainerWidth, newItems)
            else
              setHeight(columnCount, unpublishedContainerWidth, newItems)
            unpublishedContainer.masonry( 'appended', newItems);
          else
            setHeight(columnCount, containerWidth, newItems)
            # This cludgy timeout is here because FF needs a bit more time to get and set new items heights.
            setTimeout (->
              container.masonry( 'appended', newItems )
              newItems.fadeIn("fast")
              loading = false
              $('.loader').hide()
            ), 100

      if loading == false
        loading = true
        url = window.location.pathname 
        url += '?offset=' + queryOffset 
        queryOffset += queryOffsetQuantity
        $('.loader').html('LOADING...')
        $('.loader').show()

        $.ajax
          url: url
          dataType: "script"
          async: true
          complete: onComplete


  $(document).on 'click', '.inline-cta__hide', (e)->
    e.preventDefault()
    $(this).parent().parent().fadeOut()

  $('.photo-wrapper').on 'click', ->
    if $(this).hasClass 'unpublished'
      $(this).find('.photo-overlay-text').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')
      $(this).addClass('publishing')



  #company beta signup form
  $('.homepage-signup-form').submit (e) ->
    e.preventDefault();
    email = $('#email_email').val().trim()
    if !validateEmail(email)
      return $('.homepage-signup-form__message').html("Are you sure this is a valid email?").addClass('text-error').removeClass('text-success')

    callback = () -> 
      $('#email_email').val('')
      $('.homepage-signup-form__message').html('Thanks, we\'ll be in touch!').addClass('text-success').removeClass('text-error')
    $.ajax
      type:"POST"
      url: "https://docs.google.com/forms/d/1kPGuifUaBA6ihrZ8RUklZ-Zrsdfk_1vb34MgIWDY1qI/formResponse"
      data: 
        'entry.1170793925': email
      complete: callback

  bindPostCaptionClickOnMobile = ->
    if $(window).width() < 571
      $('.js-photo').off 'click'
      $('.js-photo').on 'click', (e) ->
        $(e.target).closest('.js-photo').find('.js-post-info-bar').toggleClass 'active'
  bindPostCaptionClickOnMobile()

  #Nav collapse fix
  $('[data-target=".nav-collapse"]').click () -> $('.navbar-inner').toggleClass('expanded collapsed')


  # Timer for kiosk mode
  t = null
  setKioskTimer = (seconds = 60) ->
    t = setTimeout (()->window.location = 'http://devstream.me/newsletter?is_kiosk=true'), seconds * 1000 #set timer to one minute
  resetTimer = () ->
    clearTimeout t #clear timer
    setKioskTimer() #reset timer

  

  bindMobileContentMover = ->
    if $(window).width() < 571
      moveToDestination = (element) ->
        $el = $(element)
        $el.after $('.' + $el.data().sourceElement)

      moveToDestination element for element in $('.js-destination')

  bindMobileContentMover()

  if location.search.search("is_kiosk=true") > -1 || $('#is_kiosk').val() == "true"
    if location.pathname.search("newsletter") > -1 # On newsletter signup page
      $(window).on 'scroll', resetTimer

    if location.pathname.search("users") > -1 # On users#edit page
      setKioskTimer() # set timer right away
      $("#users form").on 'keyup', resetTimer
    if location.pathname.search("confirmation") > -1 # On confirmation page
      setKioskTimer(5)