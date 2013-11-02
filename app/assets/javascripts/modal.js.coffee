$(document).on 'click', '.photo-img', ->
  photo = $(this)
  photoSrc = photo.attr('src')
  logoSrc = photo.siblings().find('.company-logo-small').attr('src')
  console.log photoSrc
  console.log photo.parent().parent().attr('id')
  console.log photo.siblings().find('.company-logo-small').attr('src')
  $('.modal-body').html('<img src=' + photoSrc + '>')
  $('.modal-footer .logo').html('<img src=' + logoSrc + '>')
  $('.photo-modal').modal()
