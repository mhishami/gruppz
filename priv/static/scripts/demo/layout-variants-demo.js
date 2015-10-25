(function(){
  'use strict';

  // sidebar small
  document.querySelector('#btn-variants1')
  .addEventListener( 'click', function(){
    window.sidebar.size('sm');
  });
  // sidebar large
  document.querySelector('#btn-variants2')
  .addEventListener( 'click', function(){
    window.sidebar.size('lg');
  });
  // hide/show sidebar
  document.querySelector('#btn-variants3')
  .addEventListener( 'click', function(){
    if (window.sidebar.options.visible) {
      window.sidebar.hide();
    } else{
      window.sidebar.show();
    }
  });
  // sidebar right
  document.querySelector('#btn-variants4')
  .addEventListener( 'click', function(){
    window.sidebar.align('right');
  });
  // sidebar left
  document.querySelector('#btn-variants5')
  .addEventListener( 'click', function(){
    window.sidebar.align('left');
  });
  // rtl direction
  var rtl = false;
  document.querySelector('#btn-variants6')
  .addEventListener( 'click', function(){
    if (rtl) {
      window.wh.rtl(false);
      window.wc.rtl(false);
      window.sidebar.rtl(false);
      window.wf.rtl(false);
    } else{
      window.wh.rtl(true);
      window.wc.rtl(true);
      window.sidebar.rtl(true);
      window.wf.rtl(true);
    }
    rtl = (!rtl);
  });
  // header fixed
  document.querySelector('#btn-variants7')
  .addEventListener( 'click', function(){
    window.wh.fixed(true);
    window.sidebar.fixed(false);
  });
  // sidebar fixed
  document.querySelector('#btn-variants8')
  .addEventListener( 'click', function(){
    window.wh.fixed(false);
    window.sidebar.fixed(true);
  });
  // fixed all
  document.querySelector('#btn-variants9')
  .addEventListener( 'click', function(){
    window.wh.fixed(true);
    window.sidebar.fixed(true);
  });
  // nofixed
  document.querySelector('#btn-variants10')
  .addEventListener( 'click', function(){
    window.wh.fixed(false);
    window.sidebar.fixed(false);
  });

})(window);