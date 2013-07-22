container = $("#masonry")
containerWidth = container.width()
unpublishedContainer = $("#masonry.masonry-unpublished")
unpublishedContainerWidth = unpublishedContainer.width()
mode = "unpublished" if unpublishedContainer.length == 1

validateEmail = (email) -> 
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  re.test(email)

setHeight = (columnCount, containerWidth, items) ->
  $.each items, ->
    width = (containerWidth/columnCount)
    if mode == "unpublished"
      # Both image and parent li need their height set to work in FF
      $(this).find('.photo img').height(Math.round(width * $(this).data("aspect-ratio")))
      $(this).height(Math.round(width * $(this).data("aspect-ratio"))+30)
    else
      # Both image and parent li need their height set to work in FF
      $(this).find('.photo img').height(Math.round(width * $(this).data("aspect-ratio")))
      $(this).height(Math.round(width * $(this).data("aspect-ratio"))+15)

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
  columnCount = if window.innerWidth > 570 then 2 else 1
  items = $(container).find("li")
  initPublished = ->
    setHeight(columnCount, container.width(), items)
    container.masonry
      columnWidth: ->
       container.width()/columnCount
  initPublished()
  items.fadeIn("fast")

  $(window).resize ->
    initPublished()



# Infinite scroll
if $('#infinite .pagination').length
  $(window).scroll ->
    url = $('.pagination .next_page').attr('href')
    # The offset needs to be at least over 190px for it to work on the iphone!
    if url && window.scrollY >= $(document).height() - window.innerHeight - 500
      $('.pagination').html('<img src="http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/loader.gif" width="16px" height="11px" />')
      $('.pagination').show()
      existingItems = $("#masonry li")

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

      $.ajax
        url: url
        dataType: "script"
        success: success
        async: true

#company beta signup form
$('.company-signup-wrapper input').keyup (e) ->
  if (e.which && e.which == 13) then submitSignupForm()

$('.company-signup-wrapper .btn').click () -> submitSignupForm()

submitSignupForm = () ->
  email = $('#email').val().trim()
  if !validateEmail(email)
    return alert "That is not a valid email address, please correct it and try again"

  callback = () -> $('.company-signup-wrapper').html('<h4>Thanks, we\'ll be in touch!</h4><br><a href="/">Back to home page</a>')
  $.ajax
    type:"POST"
    url: "https://docs.google.com/forms/d/1kPGuifUaBA6ihrZ8RUklZ-Zrsdfk_1vb34MgIWDY1qI/formResponse"
    data: 
      'entry.1170793925': email
    success: callback
    error: callback


#Nav collapse fix
$('[data-target=".nav-collapse"]').click () -> $('.navbar-inner').toggleClass('expanded collapsed')