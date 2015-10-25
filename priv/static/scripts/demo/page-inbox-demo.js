(function(){
  'use strict';

  // activate gradient
  $.cookie( 'template_bg_grd', true );

  // this action force the existing setups before
  window.wh.setSkin('teal');
  window.sidebar.setSkin('dark');
  window.sidebar.setContext('teal');

  var $heroOverlay = $('.content-hero > .content-hero-overlay');
  // I want to change hero overlay if header skin is changed
  window.wh.on('setSkin', function(e, last, cur){
    if (cur === 'inverse' || cur === 'dark') {
      setTimeout(function(){
        var skin = window.sidebar.options.skin;
        cur = (skin==='default' || skin === 'light') ? 'light' : skin;
        cur = (cur === 'dark' ) ? 'grd-white' : cur;
        $heroOverlay.attr('class', 'content-hero-overlay bg-' + cur);
      }, 0);
    } else{
      setTimeout(function(){
        $heroOverlay.attr('class', 'content-hero-overlay bg-grd-' + cur);
      }, 0);
    }
  });


  // turn of gradient so the setting not effected on other pages
  $.cookie( 'template_bg_grd', false );
  // tell the user this page using gradient skin
  var toastr = window.toastr;
  toastr.options = {
    positionClass: 'toast-bottom-right'
  };
  // toastr.info( 'Gradient skin is enabled!' );


  // Panel Tricky: keep body overflow = visible on panel expand
  if ($('.panel[data-expand="true"]').length) {
    document.body.style.overflow = '';
  }
  $('.panel').on( 'expand', function(){
    document.body.style.overflow = '';
  });

  // show hide inbox nav
  $(document).on( 'click', function(){
    $('.inbox-paper').removeClass('open');
  })
  .on( 'click', '#toggle-inbox-nav', function(e){
    e.stopPropagation();
    $('.inbox-paper').toggleClass('open');
  });

})(window);