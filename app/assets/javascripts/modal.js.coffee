showModal = (photo) ->
  parent_item = photo.parent().parent()
  photoSrc = photo.attr('src')
  logoSrc = photo.siblings().find('.company-logo-small').attr('src')
  date = photo.siblings().find('.date').text()
  caption = parent_item.data("caption")
  subdomain = parent_item.data("subdomain")

  $('.modal-body').html('<img src=' + photoSrc + '>')
  $('.modal-logo').attr('src', logoSrc)
  $('.modal-logo').parent().attr('href', 'https://' +subdomain + '.jobcrush.co/')
  $('.modal-date').html(date)
  $('.modal-caption').html(caption)
  $('.photo-modal').modal()


$(document).on 'click', '.post__media', ->
  showModal($(this))

$('.modal-body').on 'click', ->
  $('.photo-modal').modal('hide')
