$(document).ready ->
  $(".photo_wrapper").click (e)->
      e.preventDefault()
      # $(this).parent().find(".select").toggle();
      # $(this).parent().find(".selected").toggle();

      id = $(this).find(".photo").attr("id")
