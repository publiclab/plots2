let scrollBtn = document.querySelector(".back-to-top");
window.addEventListener("scroll", function(){
      let position = window.scrollY;
      if(position < 200){
      scrollBtn.style.opacity = "0";
    }
      else{
            scrollBtn.style.opacity = "1";
      }
})
