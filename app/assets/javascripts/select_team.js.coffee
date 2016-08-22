jQuery ->
  $('.select_team').on 'ajax:success', (ev, res) ->
    window.location = res.redirect || '/'
