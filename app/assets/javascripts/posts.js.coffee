$(document).ready ->
  $(".photo-wrapper").click (e)->
      e.preventDefault()
      id = $(this).find(".photo").attr("id")
