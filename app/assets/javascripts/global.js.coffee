jQuery ->
  $('#toggle_active').on 'ajax:success', (ev, res) ->
    $('#user_drop').toggleClass 'inactive_user'
    if res.active
      $('#toggle_active').text 'Go Inactive'
    else
      $('#toggle_active').text 'Go Active'
