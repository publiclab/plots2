let scrollBtn = document.getElementsByClassName('back-to-top');

window.addEventListener('scroll', function() {
  let position = window.scrollY;

  if (position < 200) {
    scrollBtn.header.style.opacity = '0';
  } else {
    scrollBtn.header.style.opacity = '1';
  }
});
