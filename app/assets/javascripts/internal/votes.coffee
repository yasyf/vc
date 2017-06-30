jQuery ->
  $('#toggle_active').on 'ajax:success', (ev, res) ->
    $('#vote-submit').prop('disabled', not res.active)
