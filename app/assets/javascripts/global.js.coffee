$(document).ready ->
  container = $("#masonry")
  containerWidth = container.width()
  unpublishedContainer = $("#masonry.masonry-unpublished")
  unpublishedContainerWidth = unpublishedContainer.width()
  mode = "unpublished" if unpublishedContainer.length == 1

  setHeight = (columnCount, containerWidth, items) ->
    $.each items, ->
      # 29 makes up for the faux gutter
      width = (containerWidth/columnCount)-29 
      if mode == "unpublished"
        # Both image and parent li need their height set to work in FF
        $(this).find('.photo-img').height(Math.round(width * $(this).data("aspect-ratio")))
        $(this).height(Math.round(width * $(this).data("aspect-ratio"))+30)
      else
        # Both image and parent li need their height set to work in FF
        $(this).find('.photo-img').height(Math.round(width * $(this).data("aspect-ratio")))
        $(this).height(Math.round(width * $(this).data("aspect-ratio"))+40)

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
  queryOffsetQuantity = 15
  queryOffset = queryOffsetQuantity 
  $(window).scroll ->
    scrollY = if window.pageYOffset != undefined then window.pageYOffset else (document.documentElement || document.body.parentNode || document.body).scrollTop
    # The offset needs to be at least over 190px for it to work on the iphone!
    if scrollY >= $(document).height() - window.innerHeight - 400
      existingItems = $("#masonry li")
      
      onComplete = ->
        loading = false
        $('.loader').hide()

      success = ->
        items = $("#masonry li")
        offset = existingItems.length - items.length
        if offset  != -8
          newItems = items.slice(offset)
        else
          newItems = items.slice(-8)

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
          container.masonry( 'appended', newItems );
        newItems.fadeIn("fast")

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
          success: success
          async: true
          complete: onComplete




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