(function(){
  'use strict';

  // activate gradient
  $.cookie( 'template_bg_grd', true );

  // this action force the existing setups before
  window.wh.setSkin('blue');
  window.sidebar.setSkin('dark');
  window.sidebar.setContext('blue');


  // turn of gradient so the setting not effected on other pages
  $.cookie( 'template_bg_grd', false );
  // tell the user this page using gradient skin
  var toastr = window.toastr;
  toastr.options = {
    positionClass: 'toast-bottom-right'
  };
  toastr.info( 'Gradient skin is enabled!' );

})(window);