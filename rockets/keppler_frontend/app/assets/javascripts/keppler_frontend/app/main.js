$('.items').slick({
  infinite: true,
  slidesToShow: 1,
  slidesToScroll: 1,
  nextArrow: '<button class="slick-next slick-arrow icofont-double-right"></button>',
  prevArrow: '<button class="slick-prev slick-arrow icofont-double-left"></button>',
  asNavFor: '.multiple-items',
  arrows: false,
  dots: false,
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

$('.multiple-items').slick({
  slidesToShow: 3,
  slidesToScroll: 1,
  arrows: false,
  dots: false,
  asNavFor: '.items',
  dots: true,
  focusOnSelect: true
});



// $('.single-item').slick({
//   infinite: false
// });


$(document).ready(function () {
  WebFontConfig = {
    google: {
      families: ['Lato:300,400,500,600,700,800,900', 'Fira sans:900']
    }
  };
  (function () {
    var wf = document.createElement('script');
    wf.src = ('https:' == document.location.protocol ? 'https' : 'http') + '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
    wf.type = 'text/javascript';
    wf.async = 'true';
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(wf, s);
  })();

});