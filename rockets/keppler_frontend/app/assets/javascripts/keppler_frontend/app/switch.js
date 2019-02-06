$('.keppler-switch').click(function(event) {
  event.preventDefault()
  $(this).find_by(id: 'input')
    .toggleClass('active')
    .attr('checked', $(this).find_by(id: 'input').hasClass('active'))
})
