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

$("#users form #skills").autoSuggest $.parseJSON($('#existing-tags').html()), {preFill:$('#incoming-tags').html(), startText:"Skills & Tools", asHtmlID: true, minChars:2, neverSubmit: true, emptyText: "Separate tags with a comma or tab", keyDelay:"50", selectedItemProp: "name", searchObjProps: "name", selectedValuesProp: "name"}

    # $("#skills").autoSuggest($.parseJSON('#{@tags}'), {preFill:"#{@incoming_tags}", startText:"Skills & tools", asHtmlID: true, minChars:2, neverSubmit: true, emptyText: "Separate tags with a comma or tab", keyDelay:"50", selectedItemProp: "name", searchObjProps: "name", selectedValuesProp: "name"});