$ ->
  $("#users .rating-input").change (e)->
    newVal = e.target.value
    url = $(e.target).closest("form").attr("action")
    $('#star-save-error').html('')
    $.ajax
      type:"POST"
      url: url
      data: 
        user: {star_rating: newVal}
        commit: "Save Rating"
        _method: "put"
      error: () -> $('#star-save-error').html('not saved')