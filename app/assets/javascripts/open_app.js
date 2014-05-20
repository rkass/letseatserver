var timeout;
function open_appstore() {
  window.location='http://itunes.com/';
}

function try_to_open_app() {
  timeout = setTimeout('open_appstore()', 300);
}

function helloWorld(){
  alert("Hello World!");
}
