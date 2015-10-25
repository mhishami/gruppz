(function(){
  'use strict';

  // activate gradient
  $.cookie( 'template_bg_grd', true );

  // this action force the existing setups before
  window.wh.setSkin('red');
  window.sidebar.setSkin('dark');
  window.sidebar.setContext('red');

  var $heroOverlay = $('.content-hero > .content-hero-overlay'),
  $displayName = $('.display-name'),
  $posterNav = $('.timeline-poster .nav');
  // I want to change hero overlay if header skin is changed
  window.wh.on('setSkin', function(e, last, cur){
    last = (last === 'default' || last === 'light') ? 'dark': last;
    cur = (cur === 'default' || cur === 'light') ? 'dark': cur;

    $heroOverlay.removeClass('bg-grd-' + last)
    .addClass('bg-grd-' + cur);

    $displayName.removeClass('text-' + last)
    .addClass('text-' + cur);

    $posterNav.removeClass('nav-contrast-' + last)
    .addClass('nav-contrast-' + cur);
  });


  // turn of gradient so the setting not effected on other pages
  $.cookie( 'template_bg_grd', false );
  // tell the user this page using gradient skin
  var toastr = window.toastr;
  toastr.options = {
    positionClass: 'toast-bottom-right'
  };
  toastr.info( 'Gradient skin is enabled!' );

})(window);