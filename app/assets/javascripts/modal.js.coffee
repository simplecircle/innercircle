showModal = (photo) ->
  parent_item = photo.parent().parent().parent()
  photoSrc = photo.attr('src')
  logoSrc = photo.parent().siblings().find('.post__logo--small').attr('src')
  date = photo.siblings().find('.post__date').text()
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
