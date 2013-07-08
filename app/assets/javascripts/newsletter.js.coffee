# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$('#user_email').keyup (e) ->
  if $('.other-job-category-section').hasClass 'inactive'
    $('.other-job-category-section').toggleClass 'inactive active'
    $('.other-job-category-section').slideDown()
    # Scroll to top of category form
    if $(window).width() < 570
      $('body').animate({scrollTop: $('#new_user').position().top - 60}, 400)

$('#new_user').submit () ->
  $('#new_user input[type="submit"]').attr 'disabled', true
  
$('#new_user').bind "ajax:success", (evt, xhr, status, error) ->
  $('.inline_error').hide()
  if xhr.success
    window.location = xhr.success
  else
    $('#new_user input[type="submit"]').attr 'disabled', false
  if xhr.categories
    $('#categories-error').show()
    $('#categories-error').html xhr.categories[0]
  if xhr.email
    $('#email-error').show()
    $('#email-error').html xhr.email[0]
  if xhr.other_job_category
    $('#other_job_category-error').show()
    $('#other_job_category-error').html xhr.other_job_category[0]