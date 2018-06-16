// create turbo links
var createTurboLinks = function(){
  var links = document.getElementsByTagName('a');
  for(x=0;x<links.length;x++){
    var link = links[x];
    // check for external links, make target blank if so
    if(link.href.match(/http/i) && !link.href.match(window.location.host)){
      console.log(link.href, window.location.origin)
      link.target = "_blank";
    } else {
      link.onclick = function(e){
        e.preventDefault();
        load(this.href);
      }      
    }
  }
};

// load pagse via XHR
var load = function(href, replace){
  if(!replace && href == window.location.href){ return false; }
  var key = href.split('/')[3];
  if(!key){ key = '/'; }
  $.get(href, function(r){
    $('#main').html($(r).find('#main')[0].innerHTML);
    if(replace){
      window.history.replaceState({title: key}, key, key);
    } else {
      window.history.pushState({title: key}, key, key);
    }
    createTurboLinks();
    updatePageStyling(key);
  });
};

// update styling of page
var updatePageStyling = function(key){
  if(!key || key == ''){ key = 'index'; }
  document.body.className = key;
};

// XHR-load pages when history is manipulated
window.onpopstate = function(){
  load(window.location.href, true);
};

// initial page load
$(document).ready(function(){
  createTurboLinks();
  updatePageStyling(window.location.pathname.split('/')[1]);
  document.body.style.opacity = 1;
});