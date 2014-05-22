var timeout;
function open_appstore() {
  window.location='letsEat://'
}

function try_to_open_app(auth_token) {
  timeout = setTimeout('open_appstore()', 300);
}

function helloWorld(){
  alert("Hello World!");
}
