$("#users .rating-input").change (e)->
  newVal = e.target.value
  url = $(e.target).closest("form").attr("action")
  $('#star-save-error').html('')
  $.ajax
    type:"PUT"
    url: url
    data: 
      user: {star_rating: newVal}
      commit: "Save Rating"
      _method: "put"
    success: () -> $('#star-save-error').html('saved'); setTimeout (()->$('#star-save-error').html('')), 2000
    error: () -> $('#star-save-error').html('not saved'); setTimeout (()->$('#star-save-error').html('')), 2000

$("#users form #skills").autoSuggest $.parseJSON($('#existing-tags').html()), {preFill:$('#incoming-tags').html(), startText:"Skills & Tools", asHtmlID: true, minChars:2, neverSubmit: true, emptyText: "Separate tags with a comma or tab", keyDelay:"50", selectedItemProp: "name", searchObjProps: "name", selectedValuesProp: "name"}