(function() {
  /*
  document.addEventListener('theme:variant:change', function(event) {
    var variant = event.detail.variant;
    var container = event.target;
    if (variant) {

    }
  });

  document.addEventListener('theme:cart:change', function(event) {
    var cart = event.detail.cart;
    if (cart) {

    }
  });
  
  document.addEventListener('theme:cart:init', (e) => {

  });

  document.addEventListener('theme:scroll', e => { console.log(e); });
  document.addEventListener('theme:scroll:up', e => { console.log(e); });
  document.addEventListener('theme:scroll:down', e => { console.log(e); });
  document.addEventListener('theme:resize', e => { console.log(e); });

  // document.dispatchEvent(new CustomEvent('theme:scroll:lock', {bubbles: true, detail: scrollableInnerElement}));
  // document.dispatchEvent(new CustomEvent('theme:scroll:unlock', {bubbles: true}));
  */

  let kleepContainer = document.querySelector('.kleep-container');
  let kleepButton = document.querySelector('.kleep-button');
  if (kleepContainer && kleepButton) {
    kleepContainer.append(kleepButton);
  }

  window.addEventListener('message', function(event) {
    if (event.data.action === 'addToCart') {
      
    }
  });

  // loyoly
  let loyolyContainer = document.querySelector('.loy-product-point');
  if (loyolyContainer) {
    loyolyContainer.addEventListener('click', function(){
      window.location.replace("/pages/fidelite-parrainage");
    }, false);
  }
})();