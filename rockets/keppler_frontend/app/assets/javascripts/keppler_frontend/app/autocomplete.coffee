jQuery ->
  console.log $('#status_user_name').data('autocomplete-source')
  $('#status_user_name').autocomplete
    source: $('#status_user_name').data('autocomplete-source')