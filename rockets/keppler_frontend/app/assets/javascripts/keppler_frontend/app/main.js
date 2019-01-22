$('.multiple-items').slick({
  infinite: true,
  slidesToShow: 4,
  slidesToScroll: 1,
  nextArrow: '<button class="slick-next slick-arrow icofont-double-right"></button>',
  prevArrow: '<button class="slick-prev slick-arrow icofont-double-left"></button>',
  responsive: [
    {
      breakpoint: 480,
      settings: {
        slidesToShow: 1,
        slidesToScroll: 1,
        arrows: false
      }
    },
    {
      breakpoint: 991,
      settings: {
        slidesToShow: 2,
        slidesToScroll: 1,
        arrows: false
      }
    }
  ]
});

$('.single-item').slick({
  infinite: false
});

$('.keppler-switch').click(function(event) {
  event.preventDefault()
  $(this).find('input')
    .toggleClass('active')
    .attr('checked', $(this).find('input').hasClass('active'))
})