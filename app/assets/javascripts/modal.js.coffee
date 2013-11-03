showModal = (photo) ->
  parent_item = photo.parent().parent()
  photoSrc = photo.attr('src')
  logoSrc = photo.siblings().find('.company-logo-small').attr('src')
  date = photo.siblings().find('.date').text()
  caption = parent_item.data("caption")
  subdomain = parent_item.data("subdomain")
  window.currentPhotoId= parent_item.attr('id')

  $('.modal-body').html('<img src=' + photoSrc + '>')
  $('.modal-logo').attr('src', logoSrc)
  $('.modal-logo').parent().attr('href', 'https://' +subdomain + '.jobcrush.co/')
  $('.modal-date').html(date)
  $('.modal-caption').html(caption)
  $('.photo-modal').modal()

$('.modal-body').on 'click', ->
  next_photo = $('#' + window.currentPhotoId).next().find('>.photo .photo-img')
  $('.photo-modal').modal('hide')
  showModal(next_photo)

$(document).on 'click', '.photo-img', ->
  showModal($(this))
