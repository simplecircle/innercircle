$(".company-show-in-index-form input").change (e)->
  newVal = e.target.value
  url = $(e.target).closest("form").attr("action")
  $('.save-callback-message').html('')
  $.ajax
    type:"PUT"
    url: url
    data: 
      company: {show_in_index: newVal}
      commit: "update_show_in_index"
      _method: "put"
    success: () -> $('.save-callback-message').html('saved'); setTimeout (()->$('.save-callback-message').html('')), 2000
    error: () -> $('.save-callback-message').html('not saved'); setTimeout (()->$('.save-callback-message').html('')), 2000